local class    = require "middleclass"
local Tile     = require "tile"
local monsters = require "monsters"
local util     = require "lib.util"
local MapFiller = require "map_filler"

local Map = class('Map')

local charValues = {
  ['D'] = {door = true},
  [' '] = {digged = true},
  ['.'] = {food = 0,  mana = 0},
  ['1'] = {food = 5,  mana = 0},
  ['2'] = {food = 16, mana = 0},
  ['3'] = {food = 20, mana = 0},
  ['4'] = {food = 50, mana = 0}
}

local getCharValues = function(char)
  local values = charValues[char]
  return values.food or 0, values.mana or 0, values.digged, values.door
end

function Map:getTile(x,y)
  return self.rows[y] and self.rows[y][x]
end

function Map:getTileOrError(x,y)
  if not self.rows[y]    then error("row " .. y .. " does not exist") end
  if not self.rows[y][x] then error("tile " .. x .. " does not exist in row " .. y) end
  return self.rows[y][x]
end

function Map:exists(x,y)
  local tile = self:getTile(x,y)
  return tile and not tile.digged
end

function Map:isOutOfBounds(x, y)
  return x < 1 or y < 1 or x > self.width or y > self.height
end

function Map:isSurface(x,y)
  return y == 1
end

function Map:isDigged(x,y)
  return not self:isOutOfBounds(x,y) and self:getTile(x,y).digged
end

function Map:isDiggable(x,y)
  return self:exists(x, y) and
         not self:isSurface(x,y) and
         ( self:isDigged(x,  y-1) or
           self:isDigged(x,  y+1) or
           self:isDigged(x-1,  y) or
           self:isDigged(x+1,  y) )
end

function Map:draw(cl, ct, cw, ch)
  local floor, min, max = math.floor, math.min, math.max
  local minX, minY = Tile.toTile(cl, ct)
  local maxX, maxY = Tile.toTile(cl+cw, ct+ch)
  minX, minY = max(minX, 0), max(minY, 0)
  maxX, maxY = min(maxX, self.width), min(maxY, self.height)

  love.graphics.setColor(255,255,255)
  for y=minY, maxY do
    for x=minX, maxX do
      self:getTile(x,y):draw()
    end
  end
end

function Map:getDimensions()
  return self.width * Tile.TILE_SIZE,
         self.height * Tile.TILE_SIZE
end

function Map:digg(x,y)
  local tile = self:getTileOrError(x,y)
  if tile then
    local monster = monsters.create(tile)
    self:addMonster(monster)
    tile:digg()
  end
end

function Map:update(dt)
  for monster in pairs(self.monsters) do
    monster:update(dt)
  end
end

function Map:addMonster(monster)
  if monster then
    self:getTile(monster.x, monster.y):addMonster(monster)
    self.monsters[monster] = true
  end
end

function Map:removeMonster(monster)
  self:getTile(monster.x, monster.y):removeMonster(monster)
  self.monsters[monster] = nil
end

function Map:moveMonster(monster, newTile)
  monster:getTile():removeMonster(monster)
  newTile:addMonster(monster)
  monster.x, monster.y = newTile.x, newTile.y
end

function Map:addFoodExplosion(x,y,intensity, radius)
  radius = radius or 1
  for i=x-radius, x+radius do
    for j=y-radius, y+radius do
      local tile = self:getTile(i,j)
      if tile and not tile.digged and math.random() > 0.5 then
        tile.food = tile.food + math.random(intensity)
      end
    end
  end
end

function Map:addRow()
  self.height = self.height + 1
  self.rows[self.height] = {}
  for x=1, self.width do
    self.rows[self.height][x] = Tile:new(self, x,self.height)
  end
end

function Map:initialize(width, height)
  self.width     = width
  self.height    = 0
  self.rows      = {}
  self.monsters  = {}

  for y=1, height do
    self:addRow()
  end
end

function Map.static:newFromString(str)
  local width = #(str:match("[^\n]+"))
  local map = Map:new(width, 0)
  local x,y
  for line in str:gmatch("[^\n]+") do
    map:addRow()
    x,y = 1, map.height
    for char in line:gmatch(".") do
      local food, mana, digged, door = getCharValues(char)
      local tile = map:getTileOrError(x,y)
      tile.food, tile.mana = food, mana
      if digged then map:digg(x,y) end
      if door then tile.door = true end
      x = x + 1
    end
  end
  return map
end

function Map.static:newFromFile(path)
  return Map:newFromString(love.filesystem.read(path))
end

function Map.static:newRandom(width, height)
  local map = Map:new(width, height)

  map:getTile(10,1).door = true
  map:digg(10,2)
  map:digg(10,3)
  map:digg(11,3)
  map:digg(12,3)
  map:digg(13,3)

  for i=1, math.random(5,20) do
    MapFiller:new(map):live()
  end

  return map
end

return Map

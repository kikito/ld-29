local Tile     = require "tile"
local factory  = require "monster_factory"
local util     = require "lib.util"

local Map = {}

local MapMethods  = {}
local MapMt       = {__index  = MapMethods}

function MapMethods:getTile(x,y)
  return self.rows[y] and self.rows[y][x]
end

function MapMethods:exists(x,y)
  local tile = self:getTile(x,y)
  return tile and not tile.digged
end

function MapMethods:isOutOfBounds(x, y)
  return x < 1 or y < 1 or x > self.width or y > self.height
end

function MapMethods:isSurface(x,y)
  return y == 1
end

function MapMethods:isDigged(x,y)
  return not self:isOutOfBounds(x,y) and self:getTile(x,y).digged
end

function MapMethods:isDiggable(x,y)
  return self:exists(x, y) and
         not self:isSurface(x,y) and
         ( self:isDigged(x,  y-1) or
           self:isDigged(x,  y+1) or
           self:isDigged(x-1,  y) or
           self:isDigged(x+1,  y) )
end

function MapMethods:draw(cl, ct, cw, ch)
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

function MapMethods:getDimensions()
  return self.width * Tile.TILE_SIZE,
         self.height * Tile.TILE_SIZE
end

function MapMethods:digg(x,y)
  local tile = self:getTile(x,y)
  if tile then
    local monster = factory.create(tile)
    self:addMonster(monster)
    tile:digg()
  end
end

function MapMethods:update(dt)
  for monster in pairs(self.monsters) do
    monster:update(dt)
  end
end

function MapMethods:addMonster(monster)
  if monster then
    self:getTile(monster.x, monster.y):addMonster(monster)
    self.monsters[monster] = true
  end
end

function MapMethods:removeMonster(monster)
  self:getTile(monster.x, monster.y):removeMonster(monster)
  self.monsters[monster] = nil
end

function MapMethods:moveMonster(monster, newTile)
  monster:getTile():removeMonster(monster)
  newTile:addMonster(monster)
  monster.x, monster.y = newTile.x, newTile.y
end

function MapMethods:addFoodExplosion(x,y,intensity)
  for _,d in pairs(util.directionDeltas) do
    local tile = self:getTile(x + d.dx, y + d.dy)
    if tile and not tile.digged then
      tile.food = tile.food + intensity
    end
  end
  return candidates
end

Map.newFromString = function(str)
  local width = #(str:match("[^\n]+"))
  local instance = { width = width, rows = {}, monsters={} }
  local height = 0
  local x
  for line in str:gmatch("[^\n]+") do
    height = height + 1
    instance.rows[height] = {}
    x = 1
    for char in line:gmatch(".") do
      instance.rows[height][x] = Tile.newFromChar(instance, x, height, char)
      x = x + 1
    end
  end
  instance.height = height
  return setmetatable(instance, MapMt)
end

Map.newFromFile = function(path)
  return Map.newFromString(love.filesystem.read(path))
end


Map.new = function(width, height)
  local instance = { width = width, height = height, rows = {}, monsters={} }
  for y=1, height do
    instance.rows[y] = {}
    for x=1, width do
      instance.rows[y][x] = Tile.new(instance, x,y)
    end
  end

  setmetatable(instance, MapMt)
  instance:digg(10,1)
  instance:digg(10,2)
  instance:digg(10,3)
  instance:digg(11,3)
  instance:digg(12,3)
  instance:digg(13,3)

  return instance
end

return Map

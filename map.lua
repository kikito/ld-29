local Tile     = require "tile"
local Monster  = require "monsters.monster"

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
    self:addMonster(Monster.newFromTile(tile))
    tile:digg()
  end
end

function MapMethods:addMonster(monster)
  if monster then
    self:getTile(monster.x, monster.y).monsters[monster] = true
  end
end

Map.newFromString = function(str)
  local width = #(str:match("[^\n]+"))
  local instance = { width = width, rows = {} }
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
  local instance = { width = width, height = height, rows = {} }
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

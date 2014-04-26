local Tile = require "tile"

local Level = {}

local LevelMethods  = {}
local LevelMt       = {__index  = LevelMethods}

function LevelMethods:exists(x,y)
  return self.rows[y] and self.rows[y][x]
end

LevelMethods.getTile = LevelMethods.exists

function LevelMethods:isOutOfBounds(x, y)
  return x < 1 or y < 1 or x > self.width or y > self.height
end

function LevelMethods:isDigged(x,y)
  return not self:isOutOfBounds(x,y) and not self:exists(x,y)
end

function LevelMethods:isDiggable(x,y)
  return self:exists(x, y) and
         self:isDigged(x,  y-1) or
         self:isDigged(x,  y+1) or
         self:isDigged(x-1,  y) or
         self:isDigged(x+1,  y)
end

function LevelMethods:draw(cl, ct, cw, ch)
  local floor, min, max = math.floor, math.min, math.max
  local minX, minY = Tile.toTile(cl, ct)
  local maxX, maxY = Tile.toTile(cl+cw, ct+ch)

  love.graphics.setColor(255,255,255)
  for y=minY, maxY do
    for x=minX, maxX do
      local tile = self:getTile(x,y)
      if tile then tile:draw() end
    end
  end
end

function LevelMethods:getDimensions()
  return self.width * Tile.TILE_SIZE,
         self.height * Tile.TILE_SIZE
end

function LevelMethods:digg(x,y)
  self.rows[y][x] = nil
end

Level.new = function(width, height)
  local instance = { width = width, height = height, rows = {} }
  for y=1, height do
    instance.rows[y] = {}
    for x=1, width do
      instance.rows[y][x] = Tile.new(x,y)
    end
  end

  setmetatable(instance, LevelMt)
  instance:digg(10,1)
  instance:digg(10,2)
  instance:digg(10,3)
  instance:digg(11,3)
  instance:digg(12,3)
  instance:digg(13,3)

  return instance

end

return Level

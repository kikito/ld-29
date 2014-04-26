local Tile = require "tile"

local Level = {}

local LevelMethods  = {}
local LevelMt       = {__index  = LevelMethods}

function LevelMethods:getTile(x,y)
  local row = assert(self.rows[y], y)
  return assert(row[x], x)
end

function LevelMethods:draw(cl, ct, cw, ch)
  local floor, min, max = math.floor, math.min, math.max
  local minX, minY = Tile.toTile(cl, ct)
  local maxX, maxY = Tile.toTile(cl+cw, ct+ch)

  for y=minY, maxY do
    for x=minX, maxX do
      self:getTile(x,y):draw()
    end
  end
end

function LevelMethods:getDimensions()
  return self.width * Tile.TILE_SIZE,
         self.height * Tile.TILE_SIZE
end

Level.new = function(width, height)
  local instance = { width = width, height = height, rows = {} }
  for y=1, height do
    instance.rows[y] = {}
    for x=1, width do
      instance.rows[y][x] = Tile.new(x,y)
    end
  end
  return setmetatable(instance, LevelMt)
end

return Level

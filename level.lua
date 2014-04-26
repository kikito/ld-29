local Tile = require "tile"

local Level = {}

local LevelMethods  = {}
local LevelMt       = {__index  = LevelMethods}

function LevelMethods:getTile(x,y)
  return assert(self.rows[y][x], 'tile not found: ' .. x .. ', ' .. y)
end

function LevelMethods:draw()
  for y=1, self.height do
    for x=1, self.width do
      self:getTile(x,y):draw()
    end
  end
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

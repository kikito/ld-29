local class = require 'lib.middleclass'

local Tile = class('Tile')

local TILE_SIZE = 32

function Tile:draw()
  if self.digged then
    for monster in pairs(self.monsters) do
      monster:draw()
    end
  else
    local l,t = Tile.toWorld(self.x, self.y)
    if self.food == 0 then
      love.graphics.setColor(100,100,100)
    else
      local r = 50 + math.floor((self.food) / 100 * 20)
      local g = 55 + math.floor((self.food / 100) * 200)
      local b = r
      love.graphics.setColor(r,g,b)
    end
    love.graphics.rectangle("fill", l, t, TILE_SIZE, TILE_SIZE)
  end
end

function Tile:drawBorders(r,g,b)
  love.graphics.setColor(r,g,b)
  local l,t = Tile.toWorld(self.x, self.y)
  love.graphics.rectangle("line", l, t, TILE_SIZE, TILE_SIZE)
end

function Tile:drawActive()
  self:drawBorders(255,0,0)
end

function Tile:drawDiggable()
  self:drawBorders(0,255,0)
end

function Tile:__tostring()
  if self.digged then
    local buffer, len = {},0
    for monster in pairs(self.monsters) do
      len = len + 1
      buffer[len] = tostring(monster)
    end
    return table.concat(buffer, ', ')
  else
    return ("Food: %d; Mana: %d"):format(self.food, self.mana)
  end
end

function Tile:canSpawnMonster()
  return self.food ~= 0 or self.mana ~= 0
end

function Tile:digg()
  self.food = 0
  self.mana = 0
  self.digged = true
end

function Tile:isTraversableBy(monster)
  return self.digged
end

function Tile:addMonster(monster)
  self.monsters[monster] = true
end

function Tile:removeMonster(monster)
  self.monsters[monster] = nil
end

Tile.static.TILE_SIZE = TILE_SIZE

Tile.static.toTile = function(x, y)
  local floor = math.floor
  return floor(x / TILE_SIZE) + 1, floor(y / TILE_SIZE) + 1
end

Tile.static.toWorld = function(tx, ty)
  return (tx - 1) * TILE_SIZE, (ty - 1) * TILE_SIZE
end

function Tile:initialize(map, x,y,food,mana)
  self.map       = map
  self.x         = x
  self.y         = y
  self.food      = food or 0
  self.mana      = mana or 0
  self.monsters  = {}
end

return Tile

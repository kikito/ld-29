local class = require 'lib.middleclass'
local animations = require 'animations'

local g = animations.grid

local earthFrame   = g(1, 6)[1]
local surfaceFrame = g(2, 6)[1]
local doorFrame    = g(3, 6)[1]
local slugFrame    = g(4, 6)[1]
local ratFrame     = g(5, 6)[1]
local goblinFrame  = g(6, 6)[1]

local function getFrame(tile)
  if tile.door then return doorFrame end
  if tile.y == 1 then return surfaceFrame end
  if tile.food == 0 then return earthFrame end
  if tile.food <= 10 then return slugFrame end
  if tile.food <= 16 then return ratFrame end
  if tile.food >= 17 then return goblinFrame end
end


local Tile = class('Tile')

local TILE_SIZE = 32

function Tile:draw()
  if self.digged then
    for monster in pairs(self.monsters) do
      monster:draw()
    end
  else
    local l,t = Tile.toWorld(self.x, self.y)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(animations.img, getFrame(self), l, t)
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

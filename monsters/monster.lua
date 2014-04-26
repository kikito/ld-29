local class = require 'lib.middleclass'

local Tile = require 'tile'

local Monster = class('Monster')

local directions = {
  up     = {dx=0, dy=-1},
  down   = {dx=0, dy=1},
  left   = {dx=1, dy=0},
  right  = {dx=-1,dy=0}
}
local directionNames = {'up', 'down', 'left', 'right'}

local get_keys = function(t)
  local keys,len = {},0
  for k in pairs(t) do
    len = len + 1
    keys[len] = k
  end
  return keys, len
end

function Monster:draw()
  love.graphics.setColor(255,255,255)
  local l,t = Tile.toWorld(self.x, self.y)
  local x,y = l + Tile.TILE_SIZE / 2, t + Tile.TILE_SIZE / 2
  love.graphics.circle('fill', x, y, 10)
end

function Monster:update(dt)
  self.speedAccumulator = self.speedAccumulator + self.speed * dt

  if self.speedAccumulator >= 1 then
    self.speedAccumulator = self.speedAccumulator - 1
    local tile = self:getNextTile(self.direction)
    if tile and tile:isTraversableBy(self) then
      self.x = tile.x
      self.y = tile.y
    else
      self:chooseRandomAvailableDirection()
    end
  end
end

function Monster:chooseRandomAvailableDirection()
  local candidates = {up=1,down=1,left=1,right=1}
  candidates[self.direction] = nil
  for i = 1, #directionNames do
    local directionName = directionNames[i]
    local tile = self:getNextTile(directionName)
    if not (tile and tile:isTraversableBy(self)) then
      candidates[directionName] = nil
    end
  end

  local keys, len = get_keys(candidates)
  self.direction = keys[math.random(len)]
end

function Monster:getNextTile(direction)
  local d = directions[direction]
  return self.map:getTile(self.x + d.dx, self.y + d.dy)
end

function Monster:initialize(tile)
  self.map=tile.map
  self.x=tile.x
  self.y=tile.y
  self.nutrient=tile.nutrient
  self.mana=tile.mana
  self.speed=1
  self.speedAccumulator=0
  self.direction = directionNames[math.random(#directionNames)]
end

return Monster

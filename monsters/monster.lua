local class    = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local util     = require 'lib.util'

local Tile = require 'tile'

local Monster = class('Monster'):include(Stateful)

local directionDeltas = {
  up     = {dx=0, dy=-1},
  down   = {dx=0, dy=1},
  left   = {dx=1, dy=0},
  right  = {dx=-1,dy=0}
}
local directionNames = {'up', 'down', 'left', 'right'}

function Monster:getColor()
  return 255, 255, 255
end

function Monster:draw()
  love.graphics.setColor(self:getColor())
  local l,t = self:getWorldLeftTop()
  local x,y = l + Tile.TILE_SIZE / 2, t + Tile.TILE_SIZE / 2
  love.graphics.circle('fill', x, y, 10)
  self:getTile():drawBorders(255,0,255)
end

function Monster:getWorldLeftTop()
  return Tile.toWorld(self.x, self.y)
end

function Monster:update(dt)
end

function Monster:getAvailableDirections()
  local candidates = {up=1,down=1,left=1,right=1}
  for i = 1, #directionNames do
    local directionName = directionNames[i]
    local tile = self:getNextTile(directionName)
    if not (tile and tile:isTraversableBy(self)) then
      candidates[directionName] = nil
    end
  end
  return candidates
end

function Monster:chooseRandomAvailableDirection()
  local candidates = self:getAvailableDirections()
  candidates[self.direction] = nil
  local keys, len = util.get_keys(candidates)
  self.direction = keys[math.random(len)]
end

function Monster:getNextTile(direction)
  local d = directionDeltas[direction]
  return self.map:getTile(self.x + d.dx, self.y + d.dy)
end

function Monster:getDirectionDeltas()
  local d = directionDeltas[self.direction]
  return d.dx, d.dy
end

function Monster:getTile()
  return self.map:getTile(self.x, self.y)
end

function Monster:initialize(tile)
  self.map=tile.map
  self.x=tile.x
  self.y=tile.y
  self.nutrient=tile.nutrient
  self.mana=tile.mana
  self.speed=1
  self:gotoState('Idle')
end


-- Idle state
local Idle = Monster:addState('Idle')

function Idle:enteredState(dt)
  self.moveAccumulator = 0
  self.direction        = directionNames[math.random(#directionNames)]
end

function Idle:update(dt)

  if self.moveAccumulator < 0 then
    self.moveAccumulator = self.moveAccumulator + self.speed * dt
  else
    local tile = self:getNextTile(self.direction)
    if tile and tile:isTraversableBy(self) then
      self.moveAccumulator = self.moveAccumulator + self.speed * dt
      if self.moveAccumulator >= 0.5 then
        self.moveAccumulator = self.moveAccumulator - 1
        self.map:moveMonster(self, tile)
      end
    else
      self:chooseRandomAvailableDirection()
    end
  end
end

function Idle:getColor()
  return 0,255,0
end

function Idle:getWorldLeftTop()
  local l,t = Monster.getWorldLeftTop(self)
  local dx, dy = self:getDirectionDeltas()
  local speed, accum = self.speed, self.moveAccumulator
  return l + dx * self.speed * self.moveAccumulator * Tile.TILE_SIZE,
         t + dy * self.speed * self.moveAccumulator * Tile.TILE_SIZE
end
return Monster

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
  local l,t    = Tile.toWorld(self.x, self.y)
  local dx, dy = self:getDirectionDeltas()
  local speed, accum = self.speed, self.moveAccumulator
  return l + dx * self.moveAccumulator * Tile.TILE_SIZE,
         t + dy * self.moveAccumulator * Tile.TILE_SIZE
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

function Monster:initialize(map, x, y, food, mana, options)
  self.map       = map
  self.x         = x
  self.y         = y
  self.food      = food
  self.mana      = mana
  self.speed     = options.speed    or 1
  self.hp        = options.hp       or 10
  self.voracity  = options.voracity or 1
  self.total_hp  = self.hp
  self.hungerAccumulator = 0
  self.moveAccumulator = 0
  self:gotoState('Idle')
end

function Monster:die()
  self.map:removeMonster(self)
end

function Monster:wonderAround(dt)
  if self.moveAccumulator < 0 then -- arriving to a new cell
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

function Monster:increaseHunger(dt)
  self.hungerAccumulator = self.hungerAccumulator + self.voracity * dt

  while self.hungerAccumulator >= 1 do
    self.hungerAccumulator = self.hungerAccumulator - 1
    self.hp = self.hp - 1
  end
end

function Monster:isHungry()
  return self.hp <= self.total_hp * 0.5
end

function Monster:isDead()
  return self.hp <= 0
end

function Monster:canEat()
  -- FIXME
  return false
end

function Monster:eat()
  -- FIXME
end

function Monster:canSmellFood()
  -- FIXME
  return false
end

function Monster:approachFood()
  -- FIXME
end

-- Idle state
local Idle = Monster:addState('Idle')

function Idle:enteredState(dt)
  self.direction       = directionNames[math.random(#directionNames)]
end

function Idle:update(dt)
  self:increaseHunger(dt)
  if self:isDead() then
    self:gotoState('Starving')
    self:update(0)
  elseif self:isHungry() then
    self:gotoState('Hungry')
    self:update(0)
  else
    self:wonderAround(dt)
  end
end


-- Starving state
local Starving = Monster:addState('Starving')

function Starving:enteredState()
  self.speed = 0
end

function Starving:update(dt)
  self:popAllStates()
end

function Starving:exitedState()
  self:die()
end


-- Hungry state
local Hungry = Monster:addState('Hungry')

function Hungry:update(dt)
  self:increaseHunger(dt)
  if self:isDead() then
    self:gotoState('Starving')
    self:update(0)
  elseif self:canEat() then
    self:eat()
  elseif self:canSmellFood() then
    self:approachFood()
  else
    self:wonderAround(dt)
  end
end


return Monster

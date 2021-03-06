local class       = require 'lib.middleclass'
local Stateful    = require 'lib.stateful'
local util        = require 'lib.util'
local animations  = require 'animations'

local Tile = require 'tile'

local Monster = class('Monster'):include(Stateful)

function Monster:getColor()
  return 255, 255, 255
end

function Monster:setAnimations(...)
  self.animations = animations.createGroup(...)
end

function Monster:draw()
  local l,t = self:getWorldLeftTop()
  if self.currentAnimation then
    love.graphics.setColor(255,255,255)
    self.currentAnimation:draw(animations.img, l,t)
  else
    love.graphics.setColor(self:getColor())
    local x,y = l + Tile.TILE_SIZE / 2, t + Tile.TILE_SIZE / 2
    love.graphics.circle('fill', x, y, 10)
  end
end

function Monster:getWorldLeftTop()
  local l,t    = Tile.toWorld(self.x, self.y)
  local dx, dy = self:getDirectionDeltas()
  local speed, accum = self.speed, self.moveAccumulator
  return l + dx * self.moveAccumulator * Tile.TILE_SIZE,
         t + dy * self.moveAccumulator * Tile.TILE_SIZE
end

function Monster:update(dt)
  if self.currentAnimation then self.currentAnimation:update(dt) end
end

function Monster:getAvailableDirections()
  local candidates = {up=1,down=1,left=1,right=1}
  for i = 1, #util.directionNames do
    local directionName = util.directionNames[i]
    local tile = self:getNeighborTile(directionName)
    if not (tile and tile:isTraversableBy(self)) then
      candidates[directionName] = nil
    end
  end
  return candidates
end

function Monster:chooseRandomAvailableDirection()
  local candidates = self:getAvailableDirections()
  local keys, len = util.get_keys(candidates)
  self:setDirection(keys[math.random(len)])
end

function Monster:setDirection(direction)
  self.direction = direction
end

function Monster:getNeighborTile(direction)
  local d = util.directionDeltas[direction]
  return self.map:getTile(self.x + d.dx, self.y + d.dy)
end

function Monster:getDirectionDeltas()
  local d = util.directionDeltas[self.direction]
  if not d then
    error(require('inspect')(self, {depth = 1}))
  end
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

function Monster:__tostring()
  return ("%s- HP: %d, Food: %d, dir: %s"):format(self.class.name, self.hp, self.food, self.direction)
end

function Monster:die()
  self.map:removeMonster(self)
end

function Monster:turnsWhileWandering(dt)
  self.turnAccumulator = self.turnAccumulator + dt
  if self.moveAccumulator > 0.1 then return false end
  if math.random() < self.turnAccumulator then
    self.turnAccumulator = 0
    return true
  end
end


function Monster:wonderAround(dt)
  if self.moveAccumulator < 0 then -- arriving to a new cell
    self.moveAccumulator = self.moveAccumulator + self.speed * dt
  elseif self:turnsWhileWandering(dt) then
    self:chooseRandomAvailableDirection()
  else
    local tile = self:getNeighborTile(self.direction)
    if tile and tile:isTraversableBy(self) then
      self.moveAccumulator = self.moveAccumulator + self.speed * dt
      if self.moveAccumulator >= 0.5 then
        self.moveAccumulator = self.moveAccumulator - 1
        self.map:moveMonster(self, tile)
      end
    else
      self:collideWithTile(tile)
    end
  end
end

function Monster:collideWithTile(tile)
  self:chooseRandomAvailableDirection()
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
  self:setDirection(util.getRandomDirectionName())
  self.turnAccumulator = 0
end

function Idle:update(dt)
  if self.currentAnimation then self.currentAnimation:update(dt) end
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
  if self.currentAnimation then self.currentAnimation:update(dt) end
  self:popAllStates()
end

function Starving:exitedState()
  self:die()
end


-- Hungry state
local Hungry = Monster:addState('Hungry')

function Hungry:update(dt)
  if self.currentAnimation then self.currentAnimation:update(dt) end
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

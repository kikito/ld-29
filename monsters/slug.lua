local util     = require 'lib.util'
local Monster  = require 'monsters.monster'
local Mushroom = require 'monsters.mushroom'

local Slug = Monster:subclass('Slug')

function Slug:initialize(map, x, y, food, mana)
  self:setAnimations(
    'slug_walk_left', 'slug_walk_up', 'slug_walk_down', 'slug_walk_right',
    'slug_suck_left', 'slug_suck_up', 'slug_suck_down', 'slug_suck_right'
  )
  Monster.initialize(self, map, x, y, food, mana, {voracity = 0.5, hp = 15})
end

function Slug:getColor()
  return 0,255,0
end

function Slug:turnsWhileWandering()
  return false
end

function Slug:getActionName()
  return 'walk'
end

function Slug:setDirection(direction)
  Monster.setDirection(self, direction)
  self.currentAnimation = self.animations['slug_' .. self:getActionName() .. '_' .. direction]
  self.currentAnimation:gotoFrame(1)
end

local Idle = Slug.states.Idle

function Idle:collideWithTile(tile)
  if tile and self.food > 1 and tile.food > 1 then
    self.injectTile = tile
    self:gotoState('Injecting')
  else
    self:chooseRandomAvailableDirection()
  end
end

local Injecting = Slug:addState('Injecting')

function Injecting:getActionName()
  return 'suck'
end

function Injecting:enteredState()
  self.moveAccumulator = 0
  self.injectAccumulator = 0
  self:setDirection(self.direction)
end

function Injecting:update(dt)
  if self.currentAnimation then self.currentAnimation:update(dt) end
  if self.injectTile.digged or self.food == 0 then
    self:gotoState('Idle')
    self:update(0)
  else
    self.injectAccumulator = self.injectAccumulator + dt
    while self.injectAccumulator >= 1 do
      self.injectAccumulator = self.injectAccumulator - 1
      self.injectTile.food = self.injectTile.food + 1
      self.food = self.food - 1
    end
  end
end

function Injecting:exitedState()
  self.injectAccumulator = 0
  self.injectTile = nil
end

local Starving = Slug.states.Starving

function Starving:enteredState()
  Monster.states.Starving.enteredState(self)
  self.map:addMonster(Mushroom:new(self.map, self.x, self.y, self.food, self.mana))
end


local Hungry = Slug.states.Hungry

function Hungry:canEat()
  for i=1, #util.directionNames do
    local dir = util.directionNames[i]
    local tile = self:getNeighborTile(dir)
    if tile and tile.food > 0 then
      self.absorbTile = tile
      self.absorbDirection = dir
      return true
    end
  end
end

function Hungry:eat()
  self:gotoState('Absorbing')
end

local Absorbing = Slug:addState('Absorbing')

function Absorbing:getActionName()
  return 'suck'
end

function Absorbing:enteredState()
  self.moveAccumulator = 0
  self.absorbAccumulator = 0
  self:setDirection(self.absorbDirection)
end

function Absorbing:update(dt)
  if self.currentAnimation then self.currentAnimation:update(dt) end
  if self.absorbTile.digged or self.hp >= self.total_hp or self.absorbTile.food == 0 then
    self:gotoState('Idle')
    self:update(0)
  else
    self.absorbAccumulator = self.absorbAccumulator + dt
    while self.absorbAccumulator >= 1 do
      self.absorbAccumulator = self.absorbAccumulator - 1
      self.absorbTile.food = self.absorbTile.food - 1
      self.food = self.food + 1
      self.hp = self.hp + 4
    end
  end
end






return Slug



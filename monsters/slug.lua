local Monster  = require 'monsters.monster'

local Slug = Monster:subclass('Slug')

function Slug:initialize(map, x, y, food, mana)
  Monster.initialize(self, map, x, y, food, mana, {voracity = 0.5, hp = 15})
end

function Slug:getColor()
  return 255,255,0
end

function Slug:turnsWhileWandering()
  return false
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

function Injecting:enteredState()
  self.moveAccumulator = 0
  self.injectAccumulator = 0
end

function Injecting:update(dt)
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



local Hungry = Slug.states.Hungry

local function hasFood(self, direction)
  local tile = self:getNeighborTile(direction)
  if tile and tile.food > 0 then return tile end
end

function Hungry:canEat()
  self.absorbTile = hasFood(self, 'down') or hasFood(self, 'right') or hasFood(self, 'left') or hasFood(self, 'up')
  return self.absorbTile
end

function Hungry:eat()
  self:gotoState('Absorbing')
end

local Absorbing = Slug:addState('Absorbing')

function Absorbing:enteredState()
  self.moveAccumulator = 0
  self.absorbAccumulator = 0
end

function Absorbing:update(dt)
  if self.absorbTile.digged or self.food == 2 or self.absorbTile.food == 0 then
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



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
  print('collided')
  if self.food > 1 and tile.food > 1 then
    self.injectingTile = tile
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
  if self.injectingTile.digged or self.food == 1 then
    self:gotoState('Idle')
    self:update(0)
  else
    self.injectAccumulator = self.injectAccumulator + dt
    while self.injectAccumulator >= 1 do
      self.injectAccumulator = self.injectAccumulator - 1
      self.injectingTile.food = self.injectingTile.food + 1
      self.food = self.food - 1
    end
  end
end


return Slug



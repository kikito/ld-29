local Monster  = require 'monsters.monster'

local Rat = Monster:subclass('Rat')

function Rat:initialize(map, x, y, food, mana)
  self:setAnimations(
    'rat_walk_left', 'rat_walk_up', 'rat_walk_down', 'rat_walk_right'
  )
  Monster.initialize(self, map, x, y, food, mana, {speed=3, hp=15})
end

function Rat:getColor()
  return 100,100,100
end

function Rat:setDirection(direction)
  Monster.setDirection(self, direction)
  self.currentAnimation = self.animations['rat_walk_' .. direction]
  self.currentAnimation:gotoFrame(1)
end

return Rat

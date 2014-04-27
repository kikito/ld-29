local Monster  = require 'monsters.monster'

local Goblin = Monster:subclass('Goblin')

function Goblin:initialize(map, x, y, food, mana)
  self:setAnimations(
    'goblin_walk_left', 'goblin_walk_up', 'goblin_walk_down', 'goblin_walk_right'
  )
  Monster.initialize(self, map, x, y, food, mana, {speed=3, hp=40})
end

function Goblin:getColor()
  return 0,255,0
end

function Goblin:setDirection(direction)
  Monster.setDirection(self, direction)
  self.currentAnimation = self.animations['goblin_walk_' .. direction]
  self.currentAnimation:gotoFrame(1)
end

return Goblin

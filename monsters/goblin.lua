local Monster  = require 'monsters.monster'

local Goblin = Monster:subclass('Goblin')

function Goblin:initialize(map, x, y, food, mana)
  Monster.initialize(self, map, x, y, food, mana, {speed=3, hp=40})
end

function Goblin:getColor()
  return 0,255,0
end



return Goblin

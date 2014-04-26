local Monster  = require 'monsters.monster'

local Rat = Monster:subclass('Rat')

function Rat:initialize(map, x, y, food, mana)
  Monster.initialize(self, map, x, y, food, mana, {speed=3, hp=15})
end

function Rat:getColor()
  return 100,100,100
end

return Rat

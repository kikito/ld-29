local Monster  = require 'monsters.monster'

local Goblin = Monster:subclass('Goblin')

function Goblin:getColor()
  return 0,255,0
end



return Goblin

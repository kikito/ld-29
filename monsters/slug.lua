local Monster  = require 'monsters.monster'

local Slug = Monster:subclass('Slug')

function Slug:initialize(map, x, y, food, mana)
  Monster.initialize(self, map, x, y, food, mana, {voracity = 0.5, hp = 15})
end

function Slug:getColor()
  return 255,255,0
end

return Slug

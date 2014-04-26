local Monster  = require 'monsters.monster'

local Slug = Monster:subclass('Slug')

function Slug:getColor()
  return 255,255,0
end

return Slug

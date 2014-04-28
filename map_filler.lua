local class = require 'lib.middleclass'

local MapFiller = class('MapFiller')

local rnd = math.random

function MapFiller:initialize(map)
  self.map        = map
  self.x          = rnd(1, map.width)
  self.y          = rnd(2, map.height)
  self.angle      = rnd() * math.pi * 2
  self.speed      = rnd() * 5 + 1
  self.hp         = rnd(500)
  self.intensity  = rnd(1,5)
  self.radius     = rnd(1,3)
end

function MapFiller:live()
  while self.hp >= 0 do
    self:act()
    self.hp = self.hp - 1
  end
end

function MapFiller:act()
  local p = rnd()
  if     p < 0.3 then self:advance()
  elseif p < 0.8 then self:seed()
  else   self:rotate()
  end
end

function MapFiller:advance()
  self.x = self.x + math.floor(math.sin(self.angle) * self.speed)
  self.y = self.y + math.floor(math.cos(self.angle) * self.speed)
end

function MapFiller:seed()
  self.map:addFoodExplosion(
    self.x, self.y,
    rnd(self.intensity),
    rnd(self.radius)
  )
end

function MapFiller:rotate()
  self.angle = self.angle + rnd() * 0.2 - 0.1
end


return MapFiller

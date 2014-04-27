local Monster  = require 'monsters.monster'

local Mushroom = Monster:subclass('Mushroom')

function Mushroom:initialize(map, x, y, food, mana)
  self:setAnimations('mushroom_idle')
  Monster.initialize(self, map, x, y, food, mana, {hp = 10, speed = 0})
  self.currentAnimation = self.animations.mushroom_idle
end

function Mushroom:getColor()
  return 255,0,255
end

function Mushroom:getDirectionDeltas()
  return 0, 0
end

local Idle = Mushroom.states.Idle

function Idle:enteredState()
  self.foodExplosionAccumulator = 0
end

function Idle:update(dt)
  if self.currentAnimation then self.currentAnimation:update(dt) end
  self:increaseHunger(dt)
  if self:isDead() then
    self:gotoState('Starving')
    self:update(0)
  elseif self.food > 0 then
    self.foodExplosionAccumulator = self.foodExplosionAccumulator + dt
    if self.foodExplosionAccumulator > 1 then
      self.foodExplosionAccumulator = 0
      if math.random() < 0.3 then
        local foodUsed = math.random(self.food)
        self.map:addFoodExplosion(self.x, self.y, foodUsed)
        self.food = self.food - 1
      end
    end
  end
end

local Starving = Mushroom.states.Starving

function Starving:exitedState()
  if self.food > 1 then
    local Slug = require 'monsters.slug'
    for i=1,2 do
      self.map:addMonster(Slug:new(self.map, self.x, self.y, self.food/2, self.mana/2))
    end
  end
  self:die()
end


return Mushroom

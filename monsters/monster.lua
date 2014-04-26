local Tile = require 'tile'
local Monster = {}

local MonsterMethods = {}
local MonsterMt      = {__index = MonsterMethods}

local directions = {
  up     = {dx=0, dy=-1},
  down   = {dx=0, dy=1},
  left   = {dx=1, dy=0},
  right  = {dx=-1,dy=0}
}
local directionNames = {'up', 'down', 'left', 'right'}

local get_keys = function(t)
  local keys,len = {},0
  for k in pairs(t) do
    len = len + 1
    keys[len] = k
  end
  return keys, len
end

function MonsterMethods:draw()
  love.graphics.setColor(255,255,255)
  local l,t = Tile.toWorld(self.x, self.y)
  local x,y = l + Tile.TILE_SIZE / 2, t + Tile.TILE_SIZE / 2
  love.graphics.circle('fill', x, y, 10)
end

function MonsterMethods:update(dt)
  self.speedAccumulator = self.speedAccumulator + self.speed * dt

  if self.speedAccumulator >= 1 then
    self.speedAccumulator = self.speedAccumulator - 1
    local tile = self:getNextTile(self.direction)
    if tile and tile:isTraversableBy(self) then
      self.x = tile.x
      self.y = tile.y
    else
      self:chooseRandomAvailableDirection()
    end
  end
end

function MonsterMethods:chooseRandomAvailableDirection()
  local candidates = {up=1,down=1,left=1,right=1}
  candidates[self.direction] = nil
  for i = 1, #directionNames do
    local directionName = directionNames[i]
    local tile = self:getNextTile(directionName)
    if not (tile and tile:isTraversableBy(self)) then
      candidates[directionName] = nil
    end
  end

  local keys, len = get_keys(candidates)
  self.direction = keys[math.random(len)]
end

function MonsterMethods:getNextTile(direction)
  local d = directions[direction]
  return self.map:getTile(self.x + d.dx, self.y + d.dy)
end

Monster.new = function(map,x,y,nutrient,mana)
  return setmetatable({
    map=map,
    x=x,
    y=y,
    nutrient=nutrient,
    mana=mana,
    speed=1,
    speedAccumulator=0,
    direction = directionNames[math.random(#directionNames)]
  }, MonsterMt)
end

Monster.newFromTile = function(tile)
  if tile.mana == 0 and tile.nutrient == 0 then return nil end
  return Monster.new(
    tile.map,
    tile.x,
    tile.y,
    tile.nutrient,
    tile.mana
  )
end

return Monster

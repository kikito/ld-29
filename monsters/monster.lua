local Tile = require 'tile'
local Monster = {}

local MonsterMethods = {}
local MonsterMt      = {__index = MonsterMethods}

function MonsterMethods:draw()
  love.graphics.setColor(255,255,255)
  local l,t = Tile.toWorld(self.x, self.y)
  local x,y = l + Tile.TILE_SIZE / 2, t + Tile.TILE_SIZE / 2
  love.graphics.circle('fill', x, y, 10)
end

Monster.new = function(map,x,y,nutrient,mana)
  return setmetatable({map=map,x=x,y=y,nutrient=nutrient,mana=mana},MonsterMt)
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

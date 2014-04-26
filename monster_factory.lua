local Slug   = require 'monsters.slug'
local Rat    = require 'monsters.rat'
local Goblin = require 'monsters.goblin'

local factory = {}

factory.create = function(tile)
  local map, x, y, food, mana = tile.map, tile.x, tile.y, tile.food, tile.mana

  if food == 0 then return nil end
  if food <= 10 then return  Slug:new(map, x, y, food, mana) end
  if food <= 16 then return  Rat:new(map, x, y, food, mana) end
  if food >= 17 then return Goblin:new(map, x, y, food, mana) end
end

return factory

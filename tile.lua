local Tile = {}

local TILE_SIZE = 32

local TileMethods = {}
local TileMt      = {__index = TileMethods}

function TileMethods:draw()
  local l,t = Tile.toScreen(self.x, self.y)
  love.graphics.rectangle("line", l, t, TILE_SIZE, TILE_SIZE)
end


Tile.TILE_SIZE = TILE_SIZE

Tile.fromScreen = function(x, y)
  local floor = math.floor
  return floor(x / TILE_SIZE) + 1, floor(y / TILE_SIZE) + 1
end

Tile.toScreen = function(tx, ty)
  return (tx - 1) * TILE_SIZE, (ty - 1) * TILE_SIZE
end

Tile.new = function(x,y,nutrient,mana)
  return setmetatable({
    x         = x,
    y         = y,
    nutrient  = nutrient or 0,
    mana      = mana or 0
  }, TileMt)
end


return Tile

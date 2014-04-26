local Tile = {}

local TILE_SIZE = 32

local TileMethods = {}
local TileMt      = {__index = TileMethods}

function TileMethods:draw()
  local l,t = Tile.toWorld(self.x, self.y)
  local g = math.floor((self.nutrient / 100) * 150)
  love.graphics.setColor(100,g+100,100)
  love.graphics.rectangle("fill", l+1, t+1, TILE_SIZE-2, TILE_SIZE-2)
end

function TileMethods:drawBorders(r,g,b)
  love.graphics.setColor(r,g,b)
  local l,t = Tile.toWorld(self.x, self.y)
  love.graphics.rectangle("line", l, t, TILE_SIZE, TILE_SIZE)
end

function TileMethods:drawActive()
  self:drawBorders(255,0,0)
end

function TileMethods:drawDiggable()
  self:drawBorders(0,255,0)
end

Tile.TILE_SIZE = TILE_SIZE

Tile.toTile = function(x, y)
  local floor = math.floor
  return floor(x / TILE_SIZE) + 1, floor(y / TILE_SIZE) + 1
end

Tile.toWorld = function(tx, ty)
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

local charValues = {
  ['.'] = {nutrient = 0,  mana = 0},
  ['~'] = {nutrient = 10, mana = 0},
  ['!'] = {nutrient = 50, mana = 0}
}

Tile.newFromChar = function(x,y, char)
  local values = charValues[char]

  if values then
    return Tile.new(x,y, values.nutrient, values.mana)
  end
end



return Tile

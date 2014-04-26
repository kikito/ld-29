local Tile = {}

local TILE_SIZE = 32

local TileMethods = {}
local TileMt      = {__index = TileMethods}

function TileMethods:draw()
  if self.digged then
    for monster in pairs(self.monsters) do
      monster:draw()
    end
  else
    local l,t = Tile.toWorld(self.x, self.y)
    if self.food == 0 then
      love.graphics.setColor(100,100,100)
    else
      local r = 50 + math.floor((self.food) / 100 * 20)
      local g = 55 + math.floor((self.food / 100) * 200)
      local b = r
      love.graphics.setColor(r,g,b)
    end
    love.graphics.rectangle("fill", l, t, TILE_SIZE, TILE_SIZE)
  end
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

function TileMethods:canSpawnMonster()
  return self.food ~= 0 or self.mana ~= 0
end

function TileMethods:digg()
  self.food = 0
  self.mana = 0
  self.digged = true
end

function TileMethods:isTraversableBy(monster)
  return self.digged
end

function TileMethods:addMonster(monster)
  self.monsters[monster] = true
end

function TileMethods:removeMonster(monster)
  self.monsters[monster] = nil
end

Tile.TILE_SIZE = TILE_SIZE

Tile.toTile = function(x, y)
  local floor = math.floor
  return floor(x / TILE_SIZE) + 1, floor(y / TILE_SIZE) + 1
end

Tile.toWorld = function(tx, ty)
  return (tx - 1) * TILE_SIZE, (ty - 1) * TILE_SIZE
end

Tile.new = function(map, x,y,food,mana,digged)
  return setmetatable({
    map     = map,
    x         = x,
    y         = y,
    food  = food or 0,
    mana      = mana or 0,
    digged    = digged,
    monsters  = {}
  }, TileMt)
end

local charValues = {
  [' '] = {digged = true},
  ['.'] = {food = 0,  mana = 0},
  ['1'] = {food = 5,  mana = 0},
  ['2'] = {food = 16, mana = 0},
  ['3'] = {food = 20, mana = 0},
  ['4'] = {food = 50, mana = 0}
}

Tile.newFromChar = function(map, x,y, char)
  local values = charValues[char]

  assert(values, "Invalid char: " .. char)

  return Tile.new(map, x,y, values.food, values.mana, values.digged)
end



return Tile

local Map  = require 'map'
local Tile   = require 'tile'
local gamera = require 'lib.gamera'

local isDown = love.keyboard.isDown

local map
local camera
local scrollSpeed = 200 -- pixels / second
local scroll_margin = 60 -- pixel
local scaleFactor = 0
local activeTile

local sw, sh = love.graphics.getDimensions()

function love.load()
  --map  = Map:newFromFile('maps/map1.txt')
  map  = Map:newRandom(100,100)
  camera = gamera.new(0,0, map:getDimensions())
  camera:setWindow(0,32, sw, sh-64)
  camera:setPosition(0,0)
end

local function updateCamera(dt)
  local mx, my = love.mouse.getPosition()
  local dx, dy = 0, 0

  if     mx <= scroll_margin      or isDown('left') then dx = -1
  elseif mx >= sw - scroll_margin or isDown('right')  then dx = 1
  end

  if     my <= scroll_margin      or isDown('up')   then dy = -1
  elseif my >= sh - scroll_margin or isDown('down') then dy = 1
  end

  camera:setScale(math.min(camera:getScale() + scaleFactor * dt, 2))
  local scale = camera:getScale()
  scaleFactor = 0

  local px, py = camera:toWorld(mx, my)

  activeTile = map:getTile(Tile.toTile(px, py))

  local cx, cy = camera:getPosition()
  camera:setPosition(cx + dx * scrollSpeed * 1/scale * dt,
                     cy + dy * scrollSpeed * 1/scale * dt)
end

function love.update(dt)
  updateCamera(dt)
  if love.mouse.isDown('l') then
    if activeTile and map:isDiggable(activeTile.x, activeTile.y) then
      map:digg(activeTile.x, activeTile.y)
      activeTile = nil
    end
  end
  map:update(dt)
end

function love.draw()
  camera:draw(function(l,t,w,h)
    map:draw(l,t,w,h)
    if activeTile then
      if map:isDiggable(activeTile.x, activeTile.y) then
        activeTile:drawDiggable()
      else
        activeTile:drawActive()
      end
    end
  end)
  if activeTile then
    local msg = tostring(activeTile)
    love.graphics.setColor(255,255,255)
    love.graphics.printf(msg, 200, sh-32, sw-200, 'right')
  end
end

function love.mousepressed(x, y, button)
  if button == 'wd' then
    scaleFactor = 3
  elseif button == 'wu' then
    scaleFactor = -3
  end
end

function love.keypressed(key)
  if key == "escape" then
    -- pause / go back / exit
    love.event.quit()
  end
end

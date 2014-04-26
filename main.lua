local Map  = require 'map'
local Tile   = require 'tile'
local gamera = require 'lib.gamera'

local map
local camera
local scroll_speed = 200 -- pixels / second
local scroll_margin = 60 -- pixel
local scale_factor = 0
local active_tile

function love.load()
  map  = Map.newFromFile('maps/map1.txt')
  camera = gamera.new(0,0, map:getDimensions())
end

local function updateCamera(dt)
  local sw, sh = love.graphics.getDimensions()
  local mx, my = love.mouse.getPosition()
  local dx, dy = 0, 0

  if     mx <= scroll_margin      then dx = -1
  elseif mx >= sw - scroll_margin then dx = 1
  end

  if     my <= scroll_margin      then dy = -1
  elseif my >= sh - scroll_margin then dy = 1
  end

  camera:setScale(math.min(camera:getScale() + scale_factor * dt, 2))
  local scale = camera:getScale()
  scale_factor = 0

  local px, py = camera:toWorld(mx, my)

  active_tile = map:getTile(Tile.toTile(px, py))

  local cx, cy = camera:getPosition()
  camera:setPosition(cx + dx * scroll_speed * 1/scale * dt,
                     cy + dy * scroll_speed * 1/scale * dt)


end

function love.update(dt)
  updateCamera(dt)
  if love.mouse.isDown('l') then
    if active_tile and map:isDiggable(active_tile.x, active_tile.y) then
      map:digg(active_tile.x, active_tile.y)
      active_tile = nil
    end
  end
end

function love.draw()
  camera:draw(function(l,t,w,h)
    map:draw(l,t,w,h)
    if active_tile then
      if map:isDiggable(active_tile.x, active_tile.y) then
        active_tile:drawDiggable()
      else
        active_tile:drawActive()
      end
    end
  end)
end

function love.mousepressed(x, y, button)
  if button == 'wd' then
    scale_factor = 3
  elseif button == 'wu' then
    scale_factor = -3
  end
end

function love.keypressed(key)
  if key == "escape" then
    -- pause / go back / exit
    love.event.quit()
  end
end

local Level  = require 'level'
local Tile   = require 'tile'
local gamera = require 'lib.gamera'

local level
local camera
local scroll_speed = 200 -- pixels / second
local scroll_margin = 60 -- pixel
local active_tile

function love.load()
  level  = Level.new(50, 50)
  camera = gamera.new(0,0, level:getDimensions())
end

function love.update(dt)
  local sw, sh = love.graphics.getDimensions()
  local mx, my = love.mouse.getPosition()
  local dx, dy = 0, 0

  if     mx <= scroll_margin      then dx = -1
  elseif mx >= sw - scroll_margin then dx = 1
  end

  if     my <= scroll_margin      then dy = -1
  elseif my >= sh - scroll_margin then dy = 1
  end

  local cx, cy = camera:getPosition()

  local px, py = camera:toWorld(mx, my)

  active_tile = level:getTile(Tile.toTile(px, py))

  camera:setPosition(cx + dx * scroll_speed * dt,
                     cy + dy * scroll_speed * dt)

end

function love.draw()
  camera:draw(function(l,t,w,h)
    level:draw(l,t,w,h)
    if active_tile then
      if level:isDiggable(active_tile.x, active_tile.y) then
        active_tile:drawDiggable()
      else
        active_tile:drawActive()
      end
    end
  end)
end

function love.mousepressed(x, y, button)
  if button == "l" then
    if active_tile and level:isDiggable(active_tile.x, active_tile.y) then
      level:digg(active_tile.x, active_tile.y)
      active_tile = nil
    end
  elseif button == "r" then
    -- special action? properties?
  elseif button == "wd" then
    -- zoom in?
  elseif button == "wu" then
    -- zoom out?
  end
end

function love.keypressed(key)
  if key == "escape" then
    -- pause / go back / exit
    love.event.quit()
  end
end

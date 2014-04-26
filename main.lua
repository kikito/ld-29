local Level = require 'level'

local level
function love.load()
  level = Level.new(400, 400)
end

function love.update(dt)

end

function love.draw()
  level:draw()
end

function love.mousepressed(x, y, button)
  if button == "l" then
    -- click
  elseif button == "r" then
    -- special action? properties?
  elseif button == "wd" then
    -- zoom in?
  elseif button == "wu" then
    -- zoom out?
  end
end

function love.keypressed(key)
  if key == "esc" then
    -- pause / go back / exit
    love.quit()
  end
end

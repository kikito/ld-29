local anim8 = require "lib.anim8"

local animations = {}

local data = {
  slug_walk_right = {frames = {'1-4', 1}},
  slug_walk_left  = {frames = {'1-4', 1}, flipH = true},
  slug_walk_up    = {frames = {'5-8', 1}},
  slug_walk_down  = {frames = {'5-8', 1}, flipV = true},

  slug_suck_right = {frames = {'1-4', 2}},
  slug_suck_left  = {frames = {'1-4', 2}, flipH = true},
  slug_suck_up    = {frames = {'5-8', 2}},
  slug_suck_down  = {frames = {'5-8', 2}, flipV = true},

  mushroom_idle   = {frames = {'1-4', 3}},

  rat_walk_right = {frames = {'1-4', 4}},
  rat_walk_left  = {frames = {'1-4', 4}, flipH = true},
  rat_walk_up    = {frames = {'5-8', 4}},
  rat_walk_down  = {frames = {'5-8', 4}, flipV = true},

  goblin_walk_right = {frames = {'1-4', 5}},
  goblin_walk_left  = {frames = {'1-4', 5}, flipH = true},
  goblin_walk_up    = {frames = {'5-8', 5}},
  goblin_walk_down  = {frames = {'9-12', 5}},
}

animations.img = love.graphics.newImage('media/img/bad_guy.png')
local w,h = animations.img:getDimensions()
local g = anim8.newGrid(32,32, w,h , -1, -1, 2)

animations.create = function(name)
  if not data[name] then error("wrong animation name: " .. name) end

  local params = data[name]

  local res = anim8.newAnimation(g(unpack(params.frames)), params.durations or 0.1)
  if params.flipH then res = res:flipH() end
  if params.flipV then res = res:flipV() end

  return res
end

animations.createGroup = function(...)
  local names = {...}
  local res = {}

  for i=1,#names do
    local name = names[i]
    res[name] = animations.create(name)
  end

  return res
end


return animations

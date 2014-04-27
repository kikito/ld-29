local util = {}

util.get_keys = function(t)
  local keys,len = {},0
  for k in pairs(t) do
    len = len + 1
    keys[len] = k
  end
  return keys, len
end


util.directionDeltas = {
  up     = {dx=0,  dy=-1},
  down   = {dx=0,  dy=1},
  left   = {dx=-1, dy=0},
  right  = {dx=1,  dy=0}
}

util.directionNames = {'up', 'down', 'left', 'right'}

util.getRandomDirectionName = function()
  return util.directionNames[math.random(#util.directionNames)]
end



return util

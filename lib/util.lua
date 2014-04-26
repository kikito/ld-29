local util = {}

util.get_keys = function(t)
  local keys,len = {},0
  for k in pairs(t) do
    len = len + 1
    keys[len] = k
  end
  return keys, len
end

return util

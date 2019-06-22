local caches = {}

local memory = {}

function caches.memory(source)
  local key = tostring(source)

  if not memory[key] then
    memory[key] = source()
  end

  return memory[key]
end

return caches

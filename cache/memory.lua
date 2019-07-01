local cache = {}

local memory = {}

function cache.set(key, value)
  memory[key] = value
end

function cache.get(key)
  return memory[key] or nil
end

function cache.clear(key)
  memory[key] = nil
end

function cache.clear_all()
  memory = {}
end

return cache

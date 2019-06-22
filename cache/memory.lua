local cache = {}

local memory = {}

local function hash(value)
  return tostring(value)
end

function cache.get_or_set(key)
  local k = hash(key)
  if not memory[k] then
    memory[k] = key()
  end

  return memory[k]
end

function cache.clear(key)
  memory[hash(key)] = nil
end

function cache.clear_all()
  memory = {}
end

return cache

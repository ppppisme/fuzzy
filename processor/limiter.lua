local processor = {}

local limit

function processor.init(config)
  limit = config.limit
end

function processor.process(list, _)
  if #list <= limit then
    return list
  end

  local output = {}
  for i = 1, limit do
    output[i] = list[i]
  end

  return output
end

return processor

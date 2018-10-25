local processor = {}

local attribute_name

function processor.init(config)
  attribute_name = config.attribute_name
end

function processor.process(list, _)
  local hash = {}
  local output = {}

  for _, item in pairs(list) do
    if (item[attribute_name]) then
      local value = item[attribute_name]

      if (not hash[value]) then
        table.insert(output, item)
        hash[value] = true
      end
    end
  end

  return output
end

return processor

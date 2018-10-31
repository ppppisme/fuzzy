local processor = {}

local unique_attr
local utils

function processor.init(config)
  unique_attr = config.unique_attr
  utils = require("fuzzy.utils")
end

function processor.process(list, _)
  local hash = {}
  local output = {}

  for _, item in pairs(list) do
    local value = utils.extract_value(item, unique_attr)

    if (not hash[value]) then
      table.insert(output, item)
      hash[value] = true
    end
  end

  return output
end

return processor

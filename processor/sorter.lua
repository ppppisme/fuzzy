local processor = {}

local sort_by
local utils

function processor.init(options)
  sort_by = options.sort_by
  utils = require("fuzzy.utils")
end

function processor.process(list, _)
  table.sort(list, function(a, b)
    return utils.extract_value(a, sort_by) > utils.extract_value(b, sort_by)
  end)

  return list
end

return processor

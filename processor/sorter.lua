local utils = require("fuzzy.utils")

local processor = {}

local sort_by
local order

function processor.init(options)
  sort_by = options.sort_by
  order = options.order or "DESC"
end

function processor.process(list, _)
  if order == "DESC" then
    table.sort(list, function(a, b)
      return utils.extract_value(a, sort_by) > utils.extract_value(b, sort_by)
    end)
  else
    table.sort(list, function(a, b)
      return utils.extract_value(a, sort_by) < utils.extract_value(b, sort_by)
    end)
  end

  return list
end

return processor

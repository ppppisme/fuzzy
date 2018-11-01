local utils = require("fuzzy.utils")

local processor = {}

local threshold
local thresholded_attr

function processor.init(options)
  threshold = options.threshold
  thresholded_attr = options.thresholded_attr
end

function processor.process(list, _)
  local output = {}

  local i = 1
  for _, item in pairs(list) do
    if utils.extract_value(item, thresholded_attr) >= threshold then
      output[i] = item
      i = i + 1
    end
  end

  return output
end

return processor

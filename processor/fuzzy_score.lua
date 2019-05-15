local processor = {}

local scored_attr
local utils

local function get_score(str, pattern)
  str = str:lower()
  pattern = pattern:lower()

  if str == pattern then
    return 1
  end

  local len1 = #str
  local len2 = #pattern
  if len1 < len2 then
    return 0
  end

  local penalty = 0
  local i2 = 1
  local subsequent = false

  for i1 = 1, len1 do
    if str:sub(i1, i1) == pattern:sub(i2, i2) then
      if subsequent and penalty > 0.1 then
        penalty = penalty - 0.1
      end

      subsequent = true

      if i2 == len2 then
        penalty = penalty + (len1 - i2) * 0.1

        break
      end

      i2 = i2 + 1
    else
      subsequent = false
      penalty = penalty + 1
    end
  end

  if i2 == 1 then
    penalty = len1
  end

  if penalty < 0 then
    penalty = 0
  end

  if penalty > len1 then
    penalty = len1
  end

  return (len1 - penalty) / len1
end

function processor.init(options)
  scored_attr = options.scored_attr
  utils = require("fuzzy.utils")
end

function processor.process(list, input)
  for _, item in pairs(list) do
    local value = utils.extract_value(item, scored_attr)
    item.data.fuzzy_score = get_score(value, input)
  end

  return list
end

return processor

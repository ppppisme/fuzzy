local processor = {}

local scored_attr
local utils

local function get_score(word1, word2)
  word1 = word1:lower()
  word2 = word2:lower()

  if word1 == word2 then
    return 1
  end

  local len1 = #word1
  local len2 = #word2
  if len1 < len2 then
    word1, word2 = word2, word1
    len1, len2 = len2, len1
  end

  local output = 0
  local i2 = 1
  local subsequent = false

  for i1 = 1, len1 do
    if word1:sub(i1, i1) == word2:sub(i2, i2) then
      if subsequent and output > 0.1 then
        output = output - 0.1
      end

      subsequent = true

      if i2 == len2 then
        output = output + (len1 - i2) * 0.1
        break
      end

      i2 = i2 + 1
    else
      subsequent = false

      local penalty = 1

      if i2 == 1 then
        penalty = 0.5
      end

      output = output + penalty
    end
  end

  if i2 == 1 then
    output = len1
  end

  if output < 0 then
    output = 0
  end

  if output > len1 then
    output = len1
  end

  return (len1 - output) / len1
end

function processor.init(options)
  scored_attr = options.scored_attr
  utils = require("fuzzy.utils")
end

function processor.process(list, input)
  for _, item in pairs(list) do
    local value = utils.extract_value(item, scored_attr)
    item.data.fuzzy_score = get_score(input, value)
  end

  return list
end

return processor

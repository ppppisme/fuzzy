local math = require("math")
local utils = require("fuzzy.utils")

local processors = {}

function processors.fuzzy(list, input, options)
  local function get_score(str, pattern, max_len)
    str = str:lower()
    pattern = pattern:lower()

    local len1 = #str
    local len2 = #pattern

    if len1 < len2 then
      return 0
    end

    local i2 = 1

    local score = 0

    local subsequent = false
    local includes_pattern = false

    for i1 = 1, len1 do
      if str:sub(i1, i1) == pattern:sub(i2, i2) then
        if subsequent then
          score = score + 1.5
        else
          score = score + (max_len - i1 + 1) / max_len
        end

        subsequent = true

        if i2 == len2 then
          includes_pattern = true

          -- small penalty for remaining characters to the right of str
          score = score - (len1 - i1) * 0.0001

          break
        end

        i2 = i2 + 1
      else
        subsequent = false
      end
    end

    if not includes_pattern then
      return 0
    end

    return score
  end

  local attr = options.attr

  local max_score = 0
  local max_len = 0
  local score, value
  local values = {}

  for i, item in pairs(list) do
    value = utils.extract_value(item, attr)
    values[i] = value

    max_len = math.max(#value, max_len)
  end

  for i, item in pairs(list) do
    value = values[i]

    score = get_score(value, input, max_len)
    item.data.fuzzy_score = score

    max_score = math.max(score, max_score)
  end

  -- normalize scores to fit in [0, 1] range for convenient filtering
  for _, item in pairs(list) do
    item.data.fuzzy_score = item.data.fuzzy_score / max_score
  end

  return list
end

function processors.limit(list, _, options)
  if #list <= options.limit then
    return list
  end

  local output = {}
  for i = 1, options.limit do
    output[i] = list[i]
  end

  return output
end

function processors.threshold(list, _, options)
  local output = {}

  local attr = options.attr
  local threshold = options.threshold

  local i = 1
  for _, item in pairs(list) do
    if utils.extract_value(item, attr)  >= threshold then
      output[i] = item

      i = i + 1
    end
  end

  return output
end

function processors.unique(list, _, options)
  local hash = {}
  local output = {}

  local attr = options.attr

  for _, item in pairs(list) do
    local value = utils.extract_value(item, attr)

    if (not hash[value]) then
      table.insert(output, item)
      hash[value] = true
    end
  end

  return output
end

function processors.sort(list, _, options)
  local attr = options.attr

  if options.order == "DESC" then
    table.sort(list, function(a, b)
      return utils.extract_value(a, attr) > utils.extract_value(b, attr)
    end)
  else
    table.sort(list, function(a, b)
      return utils.extract_value(a, attr) < utils.extract_value(b, attr)
    end)
  end

  return list
end

return processors

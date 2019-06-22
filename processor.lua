local utils = require("fuzzy.utils")

local processors = {}

function processors.fuzzy(list, input, options)
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

    -- if i2 == 1 then
    --   penalty = len1
    -- end

    if penalty < 0 then
      penalty = 0
    end

    if penalty > len1 then
      penalty = len1
    end

    return (len1 - penalty) / len1
  end

  local attr = options.attr

  for _, item in pairs(list) do
    local value = utils.extract_value(item, attr)
    item.data.fuzzy_score = get_score(value, input)
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
    if utils.extract_value(item, attr) >= threshold then
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

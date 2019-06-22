local utils = {}
local naughty = require("naughty")

function utils.extract_value(array, property_path)
  local output = array
  for i in string.gmatch(property_path, "[^%.]+") do
    output = output[i]
  end

  return output
end

function utils.trim(string)
  return string:gsub("^%s+", ""):gsub("%s+$", "")
end

function utils.dump(table)
  if not naughty then
    naughty = require("naughty")
  end

  local function dump(t)
    if type(t) == "table" then
        local s = "{ "
        for k, v in pairs(t) do
          if type(k) ~= "number" then k = '"'..k..'"' end
          s = s .. "["..k.."] = " .. dump(v) .. ","
        end
        return s .. "} "
    end

    return tostring(t)
  end

  naughty.notify { text = dump(table), timeout = 0 }
end

function utils.prepare_handler(handler)
  if type(handler) == "function" then
    return handler
  end

  return function (item, input, _)
    return handler.callback(item, input, handler.options or nil)
  end
end

function utils.prepare_source(source)
  if type(source) == "function" then
    return source
  end

  return function ()
    return source.callback(source.options or nil)
  end
end

return utils

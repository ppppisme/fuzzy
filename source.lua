local os
local io

local sources = {}

function sources.path()
  if not os then
    os = require("os")
  end

  if not io then
    io = require("io")
  end

  local function get_files(dir)
    local output = {}
    local p = io.popen('find -L "'..dir..'" -type f -printf "%f\n"')
    for file in p:lines() do
      table.insert(output, file)
    end

    return output
  end

  local output = {}

  for path_dir in string.gmatch(os.getenv("PATH"), "[^%:]+") do
    for _, file in pairs(get_files(path_dir)) do
      table.insert(output, {
        title = file,
        description = path_dir .. "/" .. file,
        value = file,
        data = {},
      })
    end
  end

  return output
end

function sources.client()
  local output = {}

  for _, c in ipairs(client.get()) do -- luacheck: globals client
    if c.first_tag then
      table.insert(output, {
        title = c.name,
        description = "screen: " .. c.screen.index .. ", tag: " .. c.first_tag.name,
        value = c,
      })
    end
  end

  return output
end

return sources

local os = require("os")
local io = require("io")

local source = {}

local function get_files(dir)
  local output = {}
  local p = io.popen('find -L "'..dir..'" -type f')
  for file in p:lines() do
    table.insert(output, file)
  end

  return output
end

function source.get()
  local output = {}

  for path_dir in string.gmatch(os.getenv("PATH"), "[^%:]+") do
    for _, file in pairs(get_files(path_dir)) do
      local filename = ""
      for part in string.gmatch(file, "[^%/]+") do
        filename = part
      end
      table.insert(output, {
          title = filename,
          value = filename,
          data = {},
        })
    end
  end

  return output
end

return source

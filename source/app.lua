local gtable = require("gears.table")
local gfilesystem = require("gears.filesystem")
local gio = require("lgi").Gio

local source = {}

local terminal

function source.init(options)
  terminal = options.sterminal or "urxvt"
end

-- shameless grab from awesome's menubar module
local function get_xdg_menu_dirs()
  local dirs = gfilesystem.get_xdg_data_dirs()
  table.insert(dirs, 1, gfilesystem.get_xdg_data_home())
  return gtable.map(function(dir) return dir .. "applications/" end, dirs)
end

local function rtrim(s)
  if not s then return end
  if string.byte(s, #s) == 13 then
    return string.sub(s, 1, #s - 1)
  end
  return s
end

local function parse_desktop_file(file)
  local program = { show = true, file = file }
  local desktop_entry = false

  for line in io.lines(file) do
    line = rtrim(line)
    if line:find("^%s*#") then
      (function() end)() -- I haven't found a nice way to silence luacheck here
    elseif not desktop_entry and line == "[Desktop Entry]" then
      desktop_entry = true
    else
      if line:sub(1, 1) == "[" and line:sub(-1) == "]" then
        break
      end

      for key, value in line:gmatch("(%w+)%s*=%s*(.+)") do
        program[key] = value
      end
    end
  end

  if program.Name == nil then
    program.Name = "[".. file:match("([^/]+)%.desktop$") .."]"
  end

  local cmdline = program.Exec:gsub("%%c", program.Name)
  cmdline = cmdline:gsub("%%[fuFU]", "")
  cmdline = cmdline:gsub("%%k", program.file)
  if program.icon_path then
    cmdline = cmdline:gsub("%%i", "--icon " .. program.icon_path)
  else
    cmdline = cmdline:gsub("%%i", "")
  end
  if program.Terminal == "true" then
    cmdline = terminal .. " -e " .. cmdline
  end

  program.Exec = cmdline

  return program
end

local function parser(file, programs)
  local query = gio.FILE_ATTRIBUTE_STANDARD_NAME .. "," .. gio.FILE_ATTRIBUTE_STANDARD_TYPE
  local enum = file:enumerate_children(query, gio.FileQueryInfoFlags.NONE)
  if not enum then
    return
  end

  local info = enum:next_file()
  while info do
    local file_type = info:get_file_type()
    local file_child = enum:get_child(info)
    if file_type == "REGULAR" then
      local path = file_child:get_path()
      if path then
        local success, program = pcall(parse_desktop_file, path)
        if success and program then
          table.insert(programs, program)
        end
      end
    elseif file_type == "DIRECTORY" then
      parser(file_child, programs)
    end

    info = enum:next_file()
  end

  enum:close()
end

function source.get()
  local output = {}

  local result = {}

  local dirs = get_xdg_menu_dirs()
  for _, dir_path in pairs(dirs) do
    parser(gio.File.new_for_path(dir_path), result)
  end

  for _, item in pairs(result) do
    table.insert(output, {
        title = item.Name or nil,
        description = item.Comment or nil,
        value = item.Exec or item.TryExec or nil,
        data = item,
      })
  end

  return output
end

return source

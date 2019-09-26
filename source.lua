local os
local io
local awful

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

function sources.client_options()
  local focused_client = client.focus -- luacheck: globals client

  return {
    {
      title = focused_client.sticky and "Unset sticky" or "Set sticky",
      description = "The client sticky, i.e. available on all tags",
      value = function () focused_client.sticky = not focused_client.sticky end,
    },
    {
      title = focused_client.floating and "Unset floating" or "Set floating",
      description = "The client floating state. If the client is part of the tiled layout or free floating",
      value = function () focused_client.floating = not focused_client.floating end,
    },
    {
      title = focused_client.maximized and "Unset maximized" or "Set maximized",
      description = "The client is maximized (horizontally and vertically) or not",
      value = function () focused_client.maximized = not focused_client.maximized end,
    },
    {
      title = focused_client.ontop and "Unset ontop" or "Set ontop",
      description = "The client is on top of every other windows",
      value = function () focused_client.ontop = not focused_client.ontop end,
    },
    {
      title = focused_client.fullscreen and "Unset fullscreen" or "Set fullscreen",
      description = "The client is fullscreen or not",
      value = function () focused_client.fullscreen = not focused_client.fullscreen end,
    },
    {
      title = focused_client.picture_in_picture and "Unset Picture-in-picture mod" or "Set Picture-in-picture mod",
      description = "Move client to the right bottom, make it smaller and sticky ",
      value = function ()
        if not focused_client.picture_in_picture then
          focused_client.ontop = true
          focused_client.sticky = true
          focused_client.floating = true
          focused_client.focusable = false

          if not awful then
            awful = require("awful")
          end
          local screen_geometry = awful.screen.focused().geometry

          focused_client.width = screen_geometry.width * 0.3
          focused_client.height = focused_client.width * 0.5625
          focused_client.x = screen_geometry.width - 16 - focused_client.width
          focused_client.y = screen_geometry.height - 16 - focused_client.height

          focused_client.picture_in_picture = true
        else
          focused_client.ontop = false
          focused_client.sticky = false
          focused_client.floating = false
          focused_client.focusable = true

          focused_client.picture_in_picture = false
        end
      end,
    },
  }
end

return sources

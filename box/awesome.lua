-- environment
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gio = require("lgi").Gio

local box = {}

local widget
local promptbox
local results_list

local create_item = function()
  local output = {
    widget = wibox.container.background(),
    layout = wibox.layout.fixed.horizontal,
    {
      widget = wibox.container.margin,
      right = 15,
      {
        widget = wibox.widget.imagebox(),
        forced_width = 32,
        forced_height = 32,
        resize = true,
      },
    },
    {
      widget = wibox.container.background(),
      layout = wibox.layout.fixed.vertical,
      {
        widget = wibox.widget.textbox(),
      },
      {
        widget = wibox.widget.textbox(),
      },
    }
  }

  return output
end

local function update_list(items)
  for i = 1, 5 do
    local title = ""
    local description = ""
    local image = nil

    if items[i] then
      local item = items[i]

      if (item.title) then
        title = item.title
      end
      if (item.description) then
        description = "<span color='#7c6f64'>" .. item.description .. "</span>"
      end
      if (item.image) then
        image = item.image
      end
    end

    results_list[i][1][1][1].widget:set_image(image)
    results_list[i][1][2][1].widget:set_markup_silently(title)
    results_list[i][1][2][2].widget:set_markup_silently(description)
  end
end

function box.init()
  local fg = beautiful.prompt_fg or beautiful.fg_normal
  local bg = beautiful.prompt_bg or beautiful.bg_normal

  widget = wibox {
    bg = bg,
    visible = false,
    ontop = true,
  }

  local background = require("wibox.container.background")
  local textbox = require("wibox.widget.textbox")

  promptbox = background()
  promptbox.widget = textbox()
  promptbox.fg = fg
  promptbox.bg = bg

  results_list = {
    widget = background(),
    layout = wibox.layout.fixed.vertical,
  }

  for i = 0, 5 do
    if i ~= 5 then
      table.insert(results_list, {
        widget = wibox.container.margin,
        bottom = 10,
        create_item(),
      })
    end
  end

  widget:setup {
      layout = wibox.container.margin,
      left = 20,
      right = 20,
      top = 20,
      bottom = 20,
      {
        layout = wibox.layout.fixed.vertical,
        spacing = 16,
        promptbox,
        results_list,
      }
    }
end

function box.show(list, process_callback, exe_callback)
  local focused_screen = awful.screen.focused()
  local screen_geometry = focused_screen.geometry

  widget.screen = focused_screen
  widget.width = screen_geometry.width * 0.4
  widget.height = screen_geometry.height * 0.3
  widget.x = screen_geometry.x + (screen_geometry.width - widget.width) / 2
  widget.y = screen_geometry.y + (screen_geometry.height - widget.height) / 2

  local processed_list

  local process_wrapper = function(list, input)
    processed_list = process_callback(list, input)
    update_list(processed_list)
  end

  awful.prompt.run {
    prompt = '<b>:: </b>',
    textbox = promptbox.widget,
    exe_callback = function(input)
      if input and #input > 0 then
        exe_callback(processed_list[1], input)
      end
    end,
    done_callback = function()
      box.hide()
    end,
    changed_callback = function(input)
      gio.Async.call(process_wrapper)(list, input)
    end,
  }

  widget.visible = true
end

function box.hide()
  widget.visible = false
end

function box.toggle()
  widget.visible = not widget.visible
end

return box

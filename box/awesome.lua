-- environment
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gio = require("lgi").Gio

local box = {}

local widget
local promptbox
local results_list

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

  results_list = background()
  results_list.widget = textbox()
  results_list.widget.forced_height = 300
  results_list.fg = fg
  results_list.widget.valign = "top"

  widget:setup({
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
    })
end

function box.show(list, process_callback, exe_callback)
  local focused_screen = awful.screen.focused()
  local screen_geometry = focused_screen.geometry

  widget.screen = focused_screen
  widget.width = screen_geometry.width * 0.4
  widget.height = screen_geometry.height * 0.3
  widget.x = screen_geometry.x + (screen_geometry.width - widget.width) / 2
  widget.y = screen_geometry.y + (screen_geometry.height - widget.height) / 2

  awful.prompt.run {
    textbox = promptbox.widget,
    exe_callback = function(input)
      if input and #input > 0 then
        exe_callback(list[1], input)
      end
    end,
    done_callback = function()
      box.hide()
    end,
    changed_callback = function(input)
      local output_text = ""

      local process_wrapper = function(list, input)
        local processed_list = process_callback(list, input)
        for _, item in pairs(processed_list) do
          output_text = output_text .. item.title .. "\n"
        end

        results_list.widget.markup = "<tt>" .. output_text .. "</tt>"
      end

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

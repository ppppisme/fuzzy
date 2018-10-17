-- environment
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")
local os = require("os")

local box = {}

-- dependencies
local sorter

local widget
local promptbox
local results_list

function box.init(dependencies)
  sorter = dependencies.sorter

  widget = wibox {
      x = 100,
      y = 100,
      width = 300,
      height = 500,
      bg = "#ff0000",
      visible = false,
      ontop = true,
    }

  local background = require("wibox.container.background")
  local textbox = require("wibox.widget.textbox")

  promptbox = background()
  promptbox.widget = textbox()
  promptbox.fg = beautiful.prompt_fg or beautiful.fg_normal
  promptbox.bg = beautiful.prompt_bg or beautiful.bg_normal

  results_list = background()
  results_list.widget = textbox()
  results_list.widget.forced_height = 300
  results_list.fg = "#ffffff"
  results_list.bg = "#000000"

  widget:setup({
      layout = wibox.layout.fixed.vertical,
      promptbox,
      results_list,
    })
end

function box.show(list, callback)
  awful.prompt.run {
    textbox      = promptbox.widget,
    exe_callback = function(input)
      if input and #input > 0 then
        callback(list[1], input)
      end
    end,
    done_callback = function()
      box.hide()
    end,
    changed_callback = function(input)
      local output_text = ""

      -- local start_time = os.clock()
      list = sorter.sort(list, input)
      for _, item in pairs(list) do
        output_text = output_text .. item.title .. "\n"
      end
      -- local end_time = os.clock()
      -- local elapsed_time = (end_time - start_time)
      -- naughty.notify { text = tostring(elapsed_time) }

      results_list.widget.markup = "<tt>" .. output_text .. "</tt>"
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

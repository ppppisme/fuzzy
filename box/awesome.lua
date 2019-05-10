-- environment
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gio = require("lgi").Gio
local math = require("math")

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

local function update_list(items, active_item_index)
  local active_item_index = active_item_index or 1
  local first_index = math.floor((active_item_index - 1) / 5) * 5 + 1

  for i = first_index, first_index + 4 do
    local is_active = i == active_item_index

    local title = ""
    local description = ""
    local image = nil

    if items[i] then
      local item = items[i]

      if (item.title) then
        title = item.title

        if is_active then
          title = "<span underline='single' style='italic'>" .. title .. "</span>"
        end
      end
      if (item.description) then
        description = "<span color='#7c6f64'>" .. item.description .. "</span>"
      end
      if (item.image) then
        image = item.image
      end
    end

    local relative_index = ((i - 1) % 5) + 1
    results_list[relative_index][1][1][1].widget:set_image(image)
    results_list[relative_index][1][2][1].widget:set_markup_silently(title)
    results_list[relative_index][1][2][2].widget:set_markup_silently(description)
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

  promptbox = {
    widget = wibox.widget.textbox(),
    fg = fg,
  }

  results_list = {
    widget = wibox.container.background(),
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

  update_list {}

  local processed_list
  local active_index = 1

  local process_wrapper = function(list, input)
    processed_list = process_callback(list, input)

    if #processed_list < active_index then
      active_index = 1
    end

    update_list(processed_list, active_index)
  end

  awful.prompt.run {
    prompt = '<b>:: </b>',
    textbox = promptbox.widget,
    exe_callback = function(input)
      if input and #input > 0 then
        exe_callback(processed_list[active_index], input)
      end
    end,
    done_callback = function()
      box.hide()
    end,
    changed_callback = function(input)
      gio.Async.call(process_wrapper)(list, input)
    end,
    keypressed_callback = function(mod, key, _)
      if processed_list == nil or #processed_list == 0 then
        return
      end

      if mod['Shift'] == true and key == 'Tab' then
        if active_index > 1 then
          active_index = active_index - 1
        end

        return
      end

      if key == 'Tab' then
        if active_index < #processed_list then
          active_index = active_index + 1
        end

        return
      end
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

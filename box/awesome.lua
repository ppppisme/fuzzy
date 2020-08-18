-- environment
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local math = require("math")
local utils = require("fuzzy.utils")

local box = {}

local options

local widget
local promptbox
local promptbox_info
local results_list

local ignored_keys = {
  Shift_L = true,
}

local function calc_height()
  local font_height = math.ceil(beautiful.get_font_height(beautiful.font))

  local margins = beautiful.fuzzy_margin or {
    20, 20, 20, 20
  }

  local prompt_spacing = beautiful.fuzzy_prompt_spacing or 16
  local items_margin = beautiful.fuzzy_items_margin or 10

  return margins[1]
    + margins[3]
    + prompt_spacing
    + font_height
    + (font_height * 2 + items_margin) * options.lines
end

local function create_item()
  local font_height = math.ceil(beautiful.get_font_height(beautiful.font))

  local margins = beautiful.fuzzy_margin or {
    20, 20, 20, 20
  }

  local item_margin = beautiful.fuzzy_items_margin

  return {
    widget = wibox.container.background(),
    {
      widget = wibox.container.margin,
      right = margins[2],
      left = margins[4],
      top = item_margin / 2,
      bottom = item_margin / 2,
      {
        layout = wibox.layout.fixed.horizontal,
        {
          widget = wibox.container.margin(),
          right = beautiful.fuzzy_image_spacing or 16,
          {
            widget = wibox.widget.imagebox(),
            forced_width = beautiful.fuzzy_image_size or 32,
            forced_height = beautiful.fuzzy_image_size or 32,
            resize = true,
          },
        },
        {
          layout = wibox.layout.fixed.vertical,
          {
            widget = wibox.widget.textbox(),
            forced_height = font_height,
          },
          {
            widget = wibox.widget.textbox(),
            forced_height = font_height,
          },
        },
      },
    },
  }
end

local function update_list(items, active_item_index)
  local lines = options.lines

  active_item_index = active_item_index or 1
  local first_index = math.floor((active_item_index - 1) / lines) * lines + 1

  local muted_color = beautiful.fuzzy_fg_muted or beautiful.fg_normal
  local image_spacing = beautiful.fuzzy_image_spacing or 16
  local default_bg = beautiful.fuzzy_bg

  for i = first_index, first_index + lines - 1 do
    local title = ""
    local description = ""
    local image = nil
    local item_bg = default_bg

    local relative_index = ((i - 1) % lines) + 1
    local list_element = results_list[relative_index][1]

    if items[i] then
      local item = items[i]

      if item.title then
        title = item.title

        if i == active_item_index then
          title = "<span weight='bold'>" .. title .. "</span>"
          item_bg = '#ffffff11'
        end
      end
      if item.description then
        description = "<span color='" .. muted_color .. "'>" .. item.description .. "</span>"
      end
      if item.image and utils.trim(item.image) ~= "" then
        image = item.image
      end
    end

    list_element.widget:set_bg(item_bg)

    local item_content_element = list_element[1][1]

    if image ~= nil then
      item_content_element[1][1].widget:set_image(image)

      item_content_element[1][1].widget.visible = true
      item_content_element[1].widget:set_right(image_spacing)
    else
      item_content_element[1][1].widget:set_image(nil)

      item_content_element[1].widget:set_right(0)
      item_content_element[1][1].widget.visible = false
    end

    item_content_element[2][1].widget:set_markup_silently(title)
    item_content_element[2][2].widget:set_markup_silently(description)
  end
end

function box.init(_options)
  options = _options or {}

  widget = wibox {
    bg = beautiful.fuzzy_bg or beautiful.bg_normal,
    fg = beautiful.fuzzy_fg or beautiful.fg_normal,
    visible = false,
    ontop = true,
    border_width = beautiful.fuzzy_border_width or beautiful.border_width,
    border_color = beautiful.fuzzy_border_color or beautiful.border_focus,
  }

  promptbox = {
    widget = wibox.widget.textbox(),
  }

  promptbox_info = {
    align = "right",
    valign = "center",
    widget = wibox.widget.textbox(),
  }

  local margins = beautiful.fuzzy_margin or {
    20, 20, 20, 20
  }

  local promptbox_container = {
    widget = wibox.container.margin,
    right = margins[2],
    left = margins[4],
    {
      layout = wibox.layout.align.horizontal,
      promptbox,
      promptbox_info,
    },
  }

  results_list = {
    widget = wibox.container.background,
    layout = wibox.layout.fixed.vertical,
  }

  for _ = 1, options.lines do
    table.insert(results_list, {
      widget = wibox.container.margin,
      create_item(),
    })
  end

  widget:setup {
    layout = wibox.container.margin,
    top = margins[1],
    bottom = margins[3],
    {
      layout = wibox.layout.fixed.vertical,
      spacing = beautiful.fuzzy_prompt_spacing or 16,
      promptbox_container,
      results_list,
    }
  }
end

function box.show(source_callback, process_callback, exe_callback, box_options)
  local on_change = box_options.on_change or options.on_change or function () end
  local focused_screen = awful.screen.focused()
  local screen_geometry = focused_screen.geometry

  widget.screen = focused_screen
  widget.width = screen_geometry.width * 0.4
  widget.height = calc_height()
  widget.x = screen_geometry.x + (screen_geometry.width - widget.width) / 2
  widget.y = screen_geometry.y + (screen_geometry.height - widget.height) / 2

  widget.visible = true

  local list

  list = source_callback()
  update_list(list)

  local processed_list = list
  local active_index = 1

  local skip_processing = false

  local process_wrapper = function(list, input)
    if input == "" then
      processed_list = list
    elseif not skip_processing then
      processed_list = process_callback(list, input)
    end

    if #processed_list < active_index then
      active_index = 1
    end

    update_list(processed_list, active_index)

    on_change(processed_list[active_index])

    skip_processing = false
  end

  awful.prompt.run {
    prompt = beautiful.fuzzy_prompt or "<b>:: </b>",
    textbox = promptbox.widget,
    exe_callback = function(input)
      if not processed_list[active_index] then
        return
      end

      exe_callback(processed_list[active_index], input)
    end,
    done_callback = function()
      box.hide()
    end,
    changed_callback = function(input)
      local exec_time = utils.exec_time(function ()
        process_wrapper(list, input)
      end)

      promptbox_info.widget:set_markup_silently(tostring(exec_time))
    end,
    keypressed_callback = function(mod, key, _)
      if processed_list == nil or #processed_list == 0 then
        return
      end

      if ignored_keys[key] then
        skip_processing = true

        return
      end

      if mod["Shift"] == true and key == "Tab" or
         mod["Control"] == true and key == "p" then
        if active_index > 1 then
          active_index = active_index - 1
        end

        skip_processing = true

        return
      end

      if key == "Tab" or
         mod["Control"] == true and key == "n" then
        if active_index < #processed_list then
          active_index = active_index + 1
        end

        skip_processing = true

        return
      end
    end,
  }

  return box
end

function box.hide()
  update_list {}
  widget.visible = false
end

function box.toggle()
  widget.visible = not widget.visible
end

return box

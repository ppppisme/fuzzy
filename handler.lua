local awful

local handlers = {}

function handlers.jump_to(item)
  item.value:jump_to()
end

function handlers.spawn(item)
  if not awful then
    awful = require("awful")
  end

  awful.spawn(item.value)
end

function handlers.callback(item)
  item.value(item)
end

return handlers

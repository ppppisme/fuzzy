local awful = require("awful")

local launcher = {}

function launcher.init()
end

function launcher.launch(item)
  awful.spawn(item.value)
end

return launcher

local awful = require('awful')

local launcher = {}

function launcher.init(dependencies)
end

function launcher.launch(item)
  awful.spawn(item.value)
end

return launcher

local fuzzy = {}

local matcher
local sorter
local box

function fuzzy.init(options)
  matcher = options.matcher or require('fuzzy.matcher.complex')
  sorter = options.box or require('fuzzy.sorter.stupid')
  box = options.box or require('fuzzy.box.awesome')

  matcher.init {}
  sorter.init { matcher = matcher }

  box.init {
    sorter = sorter,
  }
end

function fuzzy.show(config)
  local source = config.source
  local launcher = config.launcher

  box.show(source.get(), function(item, input)
    launcher.launch(item, input)
  end)
end

return fuzzy

local fuzzy = {}

local box
local processors

function fuzzy.init(options)
  local matcher = options.matcher or require('fuzzy.matcher.complex')
  local sorter = options.box or require('fuzzy.processor.sorter')
  local limiter = options.limiter or require('fuzzy.processor.limiter')
  local unique = options.limiter or require('fuzzy.processor.unique')

  matcher.init {}
  sorter.init { matcher = matcher }
  limiter.init { limit = 5 }
  unique.init { attribute_name = 'title' }

  processors = options.processors or {
    sorter,
    unique,
    limiter,
  }

  box = options.box or require('fuzzy.box.awesome')
  box.init()
end

function fuzzy.show(config)
  local source = config.source
  local launcher = config.launcher

  local processor = function(list, input)
    for _, processor in pairs(processors) do
      list = processor.process(list, input)
    end

    return list
  end

  local executor = function(item, input)
    launcher.launch(item, input)
  end

  box.show(source.get(), processor, executor)
end

return fuzzy

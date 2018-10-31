local fuzzy = {}

local box
local processors

function fuzzy.init(options)
  local sorter = options.sorter or require('fuzzy.processor.sorter')
  local limiter = options.limiter or require('fuzzy.processor.limiter')
  local unique = options.unique or require('fuzzy.processor.unique')
  local fuzzy_score = options.fuzzy_score or require('fuzzy.processor.fuzzy_score')

  fuzzy_score.init { scored_attr = 'title' }
  unique.init { unique_attr = 'title' }
  sorter.init { sort_by = 'data.fuzzy_score' }
  limiter.init { limit = 5 }

  processors = options.processors or {
    fuzzy_score,
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

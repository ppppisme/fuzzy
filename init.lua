local fuzzy = {}

local box
local processors

local function normalize_source_output(items)
  for i, item in pairs (items) do
    items[i] = {
      title = item.title or "",
      description = item.description or "",
      value = item.value or "",
      image = item.image or "",
      data = item.data or {},
    }
  end

  return items
end

function fuzzy.init(options)
  local sorter = options.sorter or require("fuzzy.processor.sorter")
  -- local limiter = options.limiter or require("fuzzy.processor.limiter")
  local unique = options.unique or require("fuzzy.processor.unique")
  local fuzzy_score = options.fuzzy_score or require("fuzzy.processor.fuzzy_score")
  local threshold = options.threshold or require("fuzzy.processor.threshold")

  fuzzy_score.init { scored_attr = "title" }
  unique.init { unique_attr = "title" }
  sorter.init { sort_by = "data.fuzzy_score" }
  threshold.init {
    thresholded_attr = "data.fuzzy_score",
    threshold = 0.8,
  }
  -- limiter.init { limit = 20 }

  processors = options.processors or {
    fuzzy_score,
    threshold,
    sorter,
    unique,
    -- limiter,
  }

  box = options.box or require("fuzzy.box.awesome")
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

  box.show(normalize_source_output(source.get()), processor, executor)
end

return fuzzy

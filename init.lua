local fuzzy = {}

local box

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
  box = options.box or require("fuzzy.box.awesome")
  box.init()
end

function fuzzy.show(options)
  local source = options.source
  local launcher = options.launcher
  local processors = options.processors

  local processor = function(list, input)
    for _, item in pairs(processors) do
      list = item.processor(list, input, item.options)
    end

    return list
  end

  local executor = function(item, input)
    launcher.launch(item, input)
  end

  box.show(normalize_source_output(source.get()), processor, executor)
end

return fuzzy

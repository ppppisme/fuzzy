local fuzzy = {}

local box
local utils = require("fuzzy.utils")

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
  local processors = options.processors

  local processor = function(list, input)
    for _, item in pairs(processors) do
      list = item.callback(list, input, item.options)
    end

    return list
  end

  local handler = utils.prepare_handler(options.handler)

  local source = utils.prepare_source(options.source)
  local list

  if options.cache then
    list = options.cache(source)
  else
    list = source()
  end

  box.show(normalize_source_output(list), processor, handler)
end

return fuzzy

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
  local processors = options.processors

  local processor = function(list, input)
    for _, item in pairs(processors) do
      list = item.callback(list, input, item.options)
    end

    return list
  end

  local handler = options.handler
  local executor = function(item, input)
    if type(handler) == "table" then
      handler.callback(item, input, handler.options)

      return
    end

    handler(item, input)
  end

  local source = options.source
  local list

  if options.cache then
    list = options.cache(source)
  else
    if type(source) == "table" then
      list = source.callback(source.options)
    else
      list = source()
    end
  end

  box.show(normalize_source_output(list), processor, executor)
end

return fuzzy

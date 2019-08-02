local fuzzy = {}

local utils = require("fuzzy.utils")

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
  box.init(options.box_options or {})
end

function fuzzy.show(options)
  box.show (
    function()
      local source = utils.prepare_source(options.source)

      local list
      if options.cache then
        list = utils.cache(options.cache.storage, options.cache.key, source)
      else
        list = source()
      end

      return normalize_source_output(list)
    end,
    function(list, input)
      for _, item in pairs(options.processors) do
        list = item.callback(list, input, item.options)
      end

      return list
    end,
    utils.prepare_handler(options.handler),
    options.box_options or {}
  )
end

return fuzzy

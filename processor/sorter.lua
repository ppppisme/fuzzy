local naughty = require "naughty"

local processor = {}

local matcher

function processor.init(dependencies)
  matcher = dependencies.matcher
end

function processor.process(list, pattern)
  table.sort(list, function(a, b)
    local _, a_score = matcher.match(pattern, a.title)
    local _, b_score = matcher.match(pattern, b.title)

    return a_score > b_score
  end)

  return list
end

return processor

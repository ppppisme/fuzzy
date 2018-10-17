local naughty = require "naughty"

local sorter = {}

local matcher

function sorter.init(dependencies)
  matcher = dependencies.matcher
end

function sorter.sort(list, pattern)
  table.sort(list, function(a, b)
    local _, a_score = matcher.match(pattern, a.title)
    local _, b_score = matcher.match(pattern, b.title)

    return a_score > b_score
  end)

  return list
end

return sorter

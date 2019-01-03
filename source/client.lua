local source = {}

function source.get()
  local output = {}

  for _, c in ipairs(client.get()) do -- luacheck: globals client
    if c.first_tag then
      table.insert(output, {
        title = c.name,
        description = "screen: " .. c.screen.index .. ", tag: " .. c.first_tag.name,
        value = c,
      })
    end
  end

  return output
end

return source

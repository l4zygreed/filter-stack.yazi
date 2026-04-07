local FilterStack = {stack={}}
-- FilterStack.__index = FilterStack

-- function FilterStack:__call()
--   return self.stack
-- end

function FilterStack:append(obj)
  table.insert(self.stack, obj)
end

function FilterStack:pop(obj)
  return table.remove(self.stack, obj)
end


local Name = {}
Name.__index = Name

function Name:new(pattern)
  local filter = Name
  setmetatable(self, filter)
  filter.pattern = pattern

  return filter
end

function Name:call(fobj)
  return fobj:name() == self.pattern
end

function Name:__tostring()
  return string.format("<Filter: name =~ /%s/>", self.pattern)
end

return {
  FilterStack = FilterStack,
  Name = Name
}

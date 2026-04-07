local FilterStack = {
  stack={},
}
-- FilterStack.__index = FilterStack

function FilterStack:new()
  local stack = {}
  setmetatable(stack, FilterStack)
  return stack
end

function FilterStack:append(obj)
  table.insert(self.stack, obj)
end

function FilterStack:pop()
  table.remove(self.stack)
end


local Name = {}

function Name:new(pattern)
  local o = {}
  o.pattern = pattern
  o.class = "Name"

  setmetatable(o, self)
  self.__index = self
  return o
end

function Name:__call(fobj)
  if string.find(fobj.name, self.pattern) then
    return true
  end
  return false
end

function Name:__tostring()
  return string.format("<Filter: name =~ /%s/>", self.pattern)
end



local Dir = {}

function Dir:new(isdir)
  local o = {}
  o.isdir = isdir
  o.class = "Dir"

  setmetatable(o, self)
  self.__index = self
  return o
end

function Dir:__call(fobj)
  if self.isdir then
    return fobj.mime == "folder/local"
  else
    return fobj.mime ~= "folder/local"
  end
end

function Dir:__tostring()
  if self.isdir then
    return "<Filter: is_dir>"
  else
    return "<Filter: is_file>"
  end
end

local Mime = {}

function Mime:new(pattern)
  local o = {}
  o.pattern = pattern
  o.class = "Mime"

  setmetatable(o, self)
  self.__index = self
  return o
end

function Mime:__call(fobj)
  if fobj.mime ~= nil then
    if string.find(fobj.mime, self.pattern) then
      return true
    end
  end
  return false
end

function Mime:__tostring()
    return string.format("<Filter: mime =~ /%s/>", self.pattern)
end

return {
  FilterStack = FilterStack,
  Name = Name,
  Mime = Mime,
  Dir = Dir,
}

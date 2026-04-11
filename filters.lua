Name = {}

function Name:__call(fobj)
  if string.find(fobj.name, self.pattern) then
    return true
  end
  return false
end

function Name:__tostring()
  return string.format("<Filter: name =~ /%s/>", self.pattern)
end

Dir = {}

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

Mime = {}

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

Not = {}

function Not:__call(fobj)
  local f1 = setmetatable(self.f1, _G[self.f1.class])
  return not f1(fobj)
end

function Not:__tostring()
  local f1 = setmetatable(self.f1, _G[self.f1.class])
  return string.format("<Filter: not %s>", tostring(f1))
end

Or = {}

function Or:__call(fobj)
  local f1 = setmetatable(self.f1, _G[self.f1.class])
  local f2 = setmetatable(self.f2, _G[self.f2.class])
  return f1(fobj) or f2(fobj)
end

function Or:__tostring()
  local f1 = setmetatable(self.f1, _G[self.f1.class])
  local f2 = setmetatable(self.f2, _G[self.f2.class])
  return string.format("<Filter: %s or %s>", tostring(f1), tostring(f2))
end

And = {}

function And:__call(fobj)
  local f1 = setmetatable(self.f1, _G[self.f1.class])
  local f2 = setmetatable(self.f2, _G[self.f2.class])
  return f1(fobj) and f2(fobj)
end

function And:__tostring()
  local f1 = setmetatable(self.f1, _G[self.f1.class])
  local f2 = setmetatable(self.f2, _G[self.f2.class])
  return string.format("<Filter: %s and %s>", tostring(f1), tostring(f2))
end

return {
  Name = Name,
  Mime = Mime,
  Dir = Dir,
  Not = Not,
  Or = Or,
  And = And,
}

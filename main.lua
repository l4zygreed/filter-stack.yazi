---@diagnostic disable: undefined-global

local fil = require('.filters')
local filters = fil.FilterStack

local root = ya.sync(function() return cx.active.current.cwd end)
-- local files = ya.sync(function() return cx.active.current.files end)

local list_files = ya.sync(function()
    local tab = cx.active.current
    local names = {}
    for _, file in ipairs(tab.files) do
        -- Extract just the string or URL (which is Sendable)
        table.insert(names, tostring(file.url))
    end
    return names
end)

local init = function()
  local root = root()
  local id = ya.id("ft")
  local cwd = root:into_search("filter stack")
end

-- local name = function()
--   ya.dbg("cleared")
--
--   local id = ya.id("ft")
--   local cwd = root()
--
--   local f = list_files()
--   -- ya.dbg(f)
--   -- for k,v in pairs(f) do
--   --   ya.dbg(v)
--   -- end
--
--   -- ya.dbg(tostring(cwd))
--   local url = cwd:join('kek.txt')
--   -- local url = cwd:into_search('kek')
--   local files = { File { url = url, cha = fs.cha(url, true) } }
--   ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(cwd), files = {} }) })
--   ya.emit("update_files", {
--     op = fs.op("part", {
--       id = id,
--       url = Url(cwd),
--       files = files,
--     }),
--   })
--
--   ya.emit("update_files", {
--     op = fs.op("done", { id = id, url = cwd, cha = Cha { mode = tonumber("100644", 8) } }),
--   })
-- end


local function entry(self, job)
  ya.dbg(fs)
  -- local root = root()
  -- local path = tostring(root.path)

  local action = job.args[1]

  if action == 'name' then
    -- name()
    -- local value, event = ya.input {
    --   title = "Filter by name",
    --   pos = { "center", y = 0, w = 40 },
    -- }
    --
    -- if event ~= 1 then
    --   return
    -- end

    local value = "kek"
    local f = fil.Name:new(value)
    filters:append(f)

    -- local r = list_files()
    -- ya.dbg(r)
    -- ya.dbg(filters.stack)

    local root = root()
    local id = ya.id("ft")
    local cwd = root:into_search("filter stack")
    -- local cwd = root

    ya.emit("cd", { Url(cwd) })
    ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(cwd), files = {} }) })

    local url = cwd:join('kek.txt')
    local cha = fs.cha(url, true)
    local files = { File { url = url, cha = cha } }
    ya.emit("update_files", {
      op = fs.op("part", {
        id = id,
        url = Url(cwd),
        files = files,
      }),
    })

    -- for k,v in pairs(fil.FilterStack()) do
    --   ya.dbg(k)
    --   ya.dbg(v)
    -- end
  end

  -- local url = tostring(root:join('kek.txt'))
  -- ya.dbg(url)

end

return {
  entry = entry
}

---@diagnostic disable: undefined-global

local fil = require('.filters')
local root = ya.sync(function() return cx.active.current.cwd end)

local list_files = ya.sync(function()
  local tab = cx.active.current
  local names = {}
  for _, file in ipairs(tab.files) do
    table.insert(names, {
      name = file.url.name,
      mime = file:mime()
    })
  end
  return names
end)

local get_filters = ya.sync(function(state)
  local f = state.filters.stack
  return f
end)

local get_cwd = ya.sync(function(state)
  return Url(state.filters.cwd)
end)

local get_files = ya.sync(function(state)
  return state.filters.files
end)

local get_id = ya.sync(function(state)
  return state.filters.id
end)

local init = ya.sync(function(state)
  if state.filters == nil then
    state.filters = { stack = {} }

    local root = root()
    local id = ya.id("ft")
    local cwd = root:into_search("filter stack")

    local files = list_files()

    state.filters.id = id
    state.filters.cwd = tostring(cwd)
    state.filters.files = files

    ya.emit("cd", { Url(cwd) })
  end
  ya.dbg("end")
end)

local render = function()
  local id = get_id()
  local cwd = get_cwd()
  local files = get_files()
  local stack = get_filters()
  ya.dbg("got all")
  if cwd or files then
    local newfiles = {}

    ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(cwd), files = {} }) })

    for _, file in ipairs(files) do
      for _, filter in ipairs(stack) do
        setmetatable(filter, fil[filter.class])
        ya.dbg(file)
        ya.dbg(filter(file))
        if filter(file) ~= true then
          goto continue
        end
      end

      local url = cwd:join(file.name)
      local cha = fs.cha(url, true)
      if cha then
        table.insert(
          newfiles,
          File { url = url, cha = cha }
        )
      end

      ::continue::
    end

    ya.dbg("newfiles")
    ya.dbg(newfiles)
    ya.emit("update_files", {
      op = fs.op("part", {
        id = id,
        url = Url(cwd),
        files = newfiles,
      }),
    })
    ya.emit("update_files", { op = fs.op("done", { id = id, url = cwd, cha = Cha { mode = tonumber("100644", 8) } }) })
  end
end


local input = function(title)
  local value, event = ya.input {
    title = title,
    pos = { "center", y = 0, w = 40 },
  }

  if event ~= 1 then
    return
  end

  return value
end

local name = ya.sync(function(state, value)
  local f = { class = "Name", pattern = value }
  table.insert(state.filters.stack, f)
end
)

local mime = ya.sync(function(state, value)
  local f = { class = "Mime", pattern = value }
  table.insert(state.filters.stack, f)
end
)

local dir = ya.sync(function(state)
  local f = { class = "Dir", isdir = true }
  table.insert(state.filters.stack, f)
end)

local file = ya.sync(function(state)
  local f = { class = "Dir", isdir = false }
  table.insert(state.filters.stack, f)
end)

local notf = ya.sync(function(state)
  if not state.filters or #state.filters.stack < 1 then
    ya.notify({
      title = "Error",
      level = "error",
      timeout = 4,
      content = "No filter to reverse"
    })
    return -1
  end
  local f1 = table.remove(state.filters.stack)
  local f = { class = "Not", f1 = f1 }
  table.insert(state.filters.stack, f)
end)

local orf = ya.sync(function(state)
  if not state.filters or #state.filters.stack < 2 then
    ya.notify({
      title = "Error",
      level = "error",
      timeout = 4,
      content = "Not enough filters to Or"
    })
    return -1
  end
  local f2 = table.remove(state.filters.stack)
  local f1 = table.remove(state.filters.stack)
  local f = { class = "Or", f1 = f1, f2 = f2 }
  table.insert(state.filters.stack, f)
end)

local andf = ya.sync(function(state)
  if not state.filters or #state.filters.stack < 2 then
    ya.notify({
      title = "Error",
      level = "error",
      timeout = 4,
      content = "Not enough filters to Or"
    })
    return -1
  end
  local f2 = table.remove(state.filters.stack)
  local f1 = table.remove(state.filters.stack)
  local f = { class = "And", f1 = f1, f2 = f2 }
  table.insert(state.filters.stack, f)
end)

local pop = ya.sync(function(state)
  if state.filters then
    ya.dbg(#state.filters.stack)
    if #state.filters.stack >= 1 then
      table.remove(state.filters.stack)
      if #state.filters.stack < 1 then
        state.filters = nil
        ya.emit("escape", { search = true })
        return 1
      end
    end
  else
    return 1
  end
end)

local clear = ya.sync(function(state)
  if state.filters then
    state.filters = nil
    ya.emit("escape", { search = true })
  end
end)

local function entry(state, job)
  local action = job.args[1]

  if action == 'name' then
    local inp = input("By name")
    if not inp then return end
    init()
    name(inp)
  elseif action == 'mime' then
    local inp = input("By mime type")
    if not inp then return end
    init()
    mime(inp)
  elseif action == 'dir' then
    init()
    dir()
  elseif action == 'file' then
    init()
    file()
  elseif action == 'not' then
    local res = notf()
    if res == -1 then goto escape end
  elseif action == 'or' then
    local res = orf()
    if res == -1 then goto escape end
  elseif action == 'and' then
    local res = andf()
    if res == -1 then goto escape end
  elseif action == 'pop' then
    local res = pop()
    if res then goto escape end
  elseif action == 'clear' then
    clear()
    goto escape
  end
  ya.dbg("newstack")

  render()

  ::escape::
end

-- @sync entry
return {
  entry = entry
}

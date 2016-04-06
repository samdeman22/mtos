--          CONFIGURATION API
-- help for dealing with configuration files and options

local fs = require("filesystem")
local serial = require("serialization")

local conf = {}

-- small flag managing api TODO
conf.flag = {}
conf.flag.__index = conf.flag

--where flags is a table of string -> function()
function conf.flag.create(opt)
  local f = {}
  setmetatable(f, conf.flag)
  if type(flags) == "table" then
    f.opt = opt
  end
  return f
end

--TODO
function conf.flag:set(cname, flag, foo)
  if type(cname) == "string" and type(flag) == "string" and type(foo) == "function" then
    self.opt[cname][flag] = foo
  end
end

local function contains(arr, item)
  for _,v in pairs(arr) do
    if v == item then return true end
  end
  return false
end

--TODO
--call all options (or a specific option if option is passed)
function conf.flag:call(args, option)
  if option then
    for o, _ in pairs(self.opt) do
      for flag, foo in pairs(self.opt[o]) do
        if contains(args, o) then
        end
      end
    end
  else
    for flag, foo in pairs(self.opt[option]) do
        if contains(args, option) then
          if self.opt[option][flag]
        end
      end
  end
end

--the config loader, sinmply deserialize the configuration table defined at location
--(if it exists)
function conf.loadConfiguration(location)
  if fs.exists(location) then
    local f = fs.open(location)
    local t = f:read(fs.size(location))
    f:close()
    return t
  end
end

return conf
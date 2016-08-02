--          CONFIGURATION API
-- help for dealing with configuration files and options

local fs = require("filesystem")
local serial = require("serialization")

local conf = {}

-- small flag managing api TODO


local function contains(arr, item)
  for _,v in pairs(arr) do
    if v == item then return true end
  end
  return false
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

--          MT NET-TABLE API
-- api to access and interact with the global NET table

local std = require("std")
local rap = require("net/rap")
local fs = require("filesystem")
local serial = require("serialization")

--API table
local ntable = {}
local default = {["table"] = {}}

--global environment net table
if not _G["NET"] then _G["NET"] = {} end

--me, ex and mt are special aliases
--me contains the rap head that represents this machine's subnet address
--ex contains the
function ntable.init(ex, me, table)
  _G["NET"] = {["ex"] = ex, ["me"] = me, ["table"] = table}
end

--loads the NET table from /var/NET, sets the global table and returns it; if it exists
function ntable.load()
  if not fs.exists("/var/NET") then return nil end
  local f = fs.open("/var/NET")
  local t = serial.unserialize(f:read(fs.size("/var/NET")))
  if not t then error("failed to deserialize net table") end
  _G["NET"] = t
  return t
end

function ntable.save()
  if not fs.exists("/var") then fs.makeDirectory("/var") end
  local f = fs.open("/var/NET", "w")
  f:write(serial.serialize(_G["NET"]))
  f:close()
end

-- get hard address from NET table based on entry
-- expect entry as either: "ex", "mt", "me"; or an arbitrary string/number
function ntable.get(entry)
  local n = (type(entry) == "number" and entry)
        or (type(entry) == "string" and rap.base10(entry))
  if entry then
    return _G["NET"][n]
  end
  return false
end

--
function ntable.update(entry, value)
  local n = (type(entry) == "number" and entry)
        or (type(entry) == "string" and rap.base10(entry))
  if entry then
    _G["NET"][n] = value
    return true
  end
  return false
end

function ntable.remove(entry)
  local n = (type(entry) == "number" and entry)
        or (type(entry) == "string" and rap.base10(entry))
  if _G["NET"][n] then
    _G["NET"][n] = nil
    return true
  end
  return false
end

function ntable.contains(addr)
  for k, v in pairs(_G["NET"]) do
    if v == addr then return true end
  end
  return false
end

function ntable.flush()
  _G["NET"] = {table = {}}
end

--take out loops, duplicate 'mt's and 'me's etc.
--TODO
function simplify_rap(r)
  local r = r
  if not r then return nil end
  for i = #r.subnets, 1, -1 do
    if r.subnets[i] == std.mt then
      --take everything from the right of here inclusive
      local s = r:head(i)
    end

  end
  return r
end

return ntable

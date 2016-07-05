--          MT NET-TABLE API
-- api to access and interact with the global NET table

local std = require("std")
local rap = require("rap")
local nhandle = require("net/nhandle")
local fs = require("filesystem")
local serial = require("serialization")

--API table
local ntable = {}

--global environment net table
if not _G["NET"] then _G["NET"] = {table = {}} end

function ntable.init(ex, mt, me, table)
  _G["NET"] = {["ex"] = ex, ["mt"] = mt, ["me"] = me, ["table"] = table}
end

--loads the NET table from /var/NET, sets the global table and returns it; if it exists
function ntable.load()
  if not fs.exists("/var/NET") then return nil end
  local f = fs.open("/var/NET")
  local t = serial.unserialize(f:read(fs.size("/var/NET")))
  if not t then error("failed to deserialize net table") end
  _G["NET"].table = t
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
  if entry == "ex" or entry == "mt" or entry == "me"
  or entry == 127 or entry == 331 or entry == 316 then
    return _G["NET"][entry]
  elseif type(entry) == "string" then
    return _G["NET"].table[rap.base10(entry)]
  elseif type(entry) == "number" then
    return _G["NET"].table[entry]
  else
    return nil
  end
end

--
function ntable.update(entry, value)
  if entry == "ex" or entry == "mt" or entry == "me"
  or entry == 127 or entry == 331 or entry == 316 then
    _G["NET"][entry] = value
    return true
  elseif entry then
    _G["NET"].table[rap.base10(entry)] = value
    return true
  else
    return false
  end
end

function ntable.remove(entry)
  local v = rap.base10(entry)
  if _G["NET"][entry] then
    _G["NET"][entry] = nil
    return true
  elseif _G["NET"].table[v] then
    _G["NET"].table[v] = nil
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
  _G["NET"] = {["table"] = {}}
end

return ntable

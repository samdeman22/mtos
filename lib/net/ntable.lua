--          MT NET-TABLE API
-- api to access and interact with the global NET table

local std = require("std")
local rap = require("net/rap")
local nhandle = require("net/handle")
local fs = require("filesystem")
local serial = require("serialization")

--API table
local ntable = {}

--global environment net table
if not _G["NET"] then _G["NET"] = {table = {}} end

function ntable.isreserved(entry)
  return entry == "up"
  or entry == "mt"
  or entry == "me"
  or entry == std.net.rap.up
  or entry == std.net.rap.mt
  or entry == std.net.rap.me
end

function ntable.init(mt, up, me, table)
  _G["NET"] = {["mt"] = mt, ["up"] = up, ["me"] = me, ["table"] = table}
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
  if ntable.isreserved(entry) then
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
  if ntable.isreserved(entry) then
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

-- create and return a new simplified version of this rap address
function ntable.simplify_rap(addr)
  if not addr then
    error("can't simplify non rap-address")
  end
  local addr = rap.create(addr.subnets)
  -- if the address is 'me' it is already as simple as possible
  if #addr.subnets == 1 and addr.subnets[1] == std.net.rap.me then
    -- return a copy
    return addr
  end
  local done = false
  -- remove 'me' segments, except in the case where 'me' is the only segment
  -- TODO this could be a lot more efficient somehow
  while not done do
    for i, subnet in ipairs(addr.subnets) do
      if subnet == std.net.rap.me then
        -- remove the segment
        addr = addr:remove(i)
        break
      elseif i == #addr.subnets then
        -- we've scanned to the end of the currently modified address, and found no problems..
        done = true
      end
    end
  end
  done = false
  while not done do
    -- short-circuit 'mt' segments - 'mt' always points to the root, and will find its way there
    for i, subnet in ipairs(addr.subnets) do
      if subnet == std.net.rap.mt then
        addr = addr:head(#addr.subnets - i + 1)
      elseif i == #addr.subnets then
        -- we've scanned to the end of the currently modified address, and found no problems..
        done = true
      end
    end
  end
  -- resolve loops: count the number of indirections vs the number of 'up' segments
  -- TODO
  return addr
end

return ntable

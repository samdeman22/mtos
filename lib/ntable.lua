--          MT NET-TABLE API
-- api to access and interact with the global NET table

local std = require("std")
local rap = require("rap")
local nhandle = require("nhandle")
local fs = require("filesystem")
local serial = require("serialization")

--API table
local ntable = {}

--global environment net table
if not _G["NET"] then _G["NET"] = {ex = nil, mt = nil, me = nil, table = {}} end

function ntable.set(ex, mt, me, table)
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

--
function ntable.update(entry, value)
  if entry == "ex" or entry == "mt" or entry == "me" then
    _G["NET"][entry] = value
    return true
  elseif entry then
    _G["NET"].table[rap.fromstring(entry)] = value
    return true
  else
    return false
  end
end

function ntable.get(entry)
  if entry == "ex" or entry == "mt" or entry == "me" then
    return _G["NET"][entry]
  elseif entry then
    return _G["NET"].table[rap.fromstring(entry)]
  else
    return nil
  end
end

function ntable.remove(entry)
  if _G["NET"][entry] then
    _G["NET"][entry] = nil
    return true
  elseif _G["NET"].table[rap.fromstring(entry)] then
    _G["NET"].table[rap.fromstring(entry)] = nil
    return true
  end
  return false
end

function ntable.save()
  if not fs.exists("/var") then fs.makeDirectory("/var") end
  local f = fs.open("/var/NET", "w")
  f:write(serial.serialize(_G["NET"]))
  f:close()
end

function ntable.flushAll()
  _G["NET"] = {["table"] = {}}
end

function ntable.flushTable()
  _G["NET"].table = {}
end

function ntable.encodePacket(packet, to, from)
  packet.p = "NET"
  packet.to = to
  packet.from = from
end

--optional mac to seek specific device
function ntable.seek(mac)
  
  local nh = nhandle.create(0, function(self, client)
    
    --on client handle
    if packet.content then
      local packet = serial.serialize(packet.content)
      if not packet then error("could not serialize NET-TABLE response from "..packet.from); return nil end
      --local  ntable.decodePacket(packet.content)
    else
      print("malformed packet on client handler for port "..self.port)
    end
    
  end)
  
  nh.modem.broadcast(std.ports.NET, std.signatures.SEEK)
end

return ntable
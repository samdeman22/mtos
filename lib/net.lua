--          MT NET-TABLE API
-- api to access and interact with the global NET table

local std = require("std")
local rap = require("net/rap")
local nhandle = require("net/handle")
local fs = require("filesystem")
local serial = require("serialization")

--[[

The NET system is designed to handle dynamic naming of machines, and routing to
named machines. The names take the form of RAP addresses (see 'net/rap').
--------

RESERVED ADDRESSES:

- MT:
The 'mt' address in any system is the designated root. All nodes should know
their parent node, 'up'; therefore, any node should be able to eventually
contact the root, and subsequently any computer in the network. All traffic goes
through the root as a result.

- UP:
The 'up' address in any system represents the parent. For a root system, 'mt' is
equivalent to 'up', which is also equivalent to 'me'.

- ME:
For any system, 'me' is the self address.

INDIRECTION ADDRESSES:

All addresses not reserved, between 'aa' and 'zz' may be used as indirection
addresses. At each node, we store a set of indirection addresses, which
represent children the system is a parent of.
--------

REQUESTS:

There are a small set of essential requests to make use of in the NET protocol.
These mostly deal with establishing parents, and parents authoritatively
providing names to children.

"DFLT" (a.k.a "default"):
The DFLT request represents a request for a default parent: i.e. a node wishes
to know which node it's parent is. A DFLT request is broadcasted; with no
specific recipient. The first NET response the node receives, it will (may)
trust.
If at any point, a node is attempting to send packets to it's mapped 'up'
address, and it reaches it's configured timeout time, the 'up' address should be
flushed, and the node will need to send out DFLT requests again for authority.

NET:
The NET request is a request sent by a parent, telling a child to update it's
NET table. The request body contains an authoritative NET table. This includes
the address of the parent - which the child may need if it's in an orphaned
state - as well as a list mapping RAP string format addresses to modem IDs. This
NET table is in the format that the parent understood; therefore, from the
child's perspective, it needs to prepend 'up' to all the received addresses.
--------

ROUTING:

The RAP address protocol is used to go hand-in-hand with the design of the NET
protocol. RAP addresses may be arbitrarily long, so that they may specify a path
from one node to another, through parent links and indirections.

What follows represents the routing for three different kinds of machine.
MT is a root/parent node, UP is a parent node, ME is an endpoint node. Each node
type has their own respective daemon to run. See '/bin/netmt.lua',
'/bin/netup.lua', and '/bin/netme.lua'.

MT:
- mt: readdress to mt
- ep: readdress to me
- me: consume segment; send to indirection address if available;
      otherwise, accept message

UP:
- mt: send to up
- up: consume segment; send to up
- me: consume segment; send to indirection address if available;
      otherwise, accept message

ME:
- mt: send to up
- up: consume segment; send to up
- me: consume segment; accept message

]]

--API table
local net = {}

--global environment net table
if not _G["NET"] then _G["NET"] = {table = {}} end

function net.isreserved(entry)
  return entry == "up"
  or entry == "mt"
  or entry == "me"
  or entry == std.net.rap.up
  or entry == std.net.rap.mt
  or entry == std.net.rap.me
end

function net.init(mt, up, me, table)
  _G["NET"] = {["mt"] = mt, ["up"] = up, ["me"] = me, ["table"] = table}
end

--loads the NET table from /var/NET, sets the global table and returns it; if it exists
function net.load()
  if not fs.exists("/var/NET") then return nil end
  local f = fs.open("/var/NET")
  local t = serial.unserialize(f:read(fs.size("/var/NET")))
  if not t then error("failed to deserialize net table") end
  _G["NET"].table = t
  return t
end

function net.save()
  if not fs.exists("/var") then fs.makeDirectory("/var") end
  local f = fs.open("/var/NET", "w")
  f:write(serial.serialize(_G["NET"]))
  f:close()
end

-- get hard address from NET table based on entry
-- expect entry as either: "up", "mt", "me"; or an arbitrary string/number
function net.get(entry)
  if net.isreserved(entry) then
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
function net.update(entry, value)
  if net.isreserved(entry) then
    _G["NET"][entry] = value
    return true
  elseif entry then
    _G["NET"].table[rap.base10(entry)] = value
    return true
  else
    return false
  end
end

function net.remove(entry)
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

function net.contains(addr)
  for k, v in pairs(_G["NET"]) do
    if v == addr then return true end
  end
  return false
end

function net.flush()
  _G["NET"] = {["table"] = {}}
end

-- create and return a new simplified version of this rap address
function net.simplify_rap(addr)
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

return net

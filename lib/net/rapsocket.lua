--          MT NET-HANDLE API
-- built on top of modhandle, RAP and NET for easy rap-level networking

local serial = require("serialization")
local net = require("net/table")
local rap = require("net/rap")
local socket = require("net/socket")
local rapsocket = {}
rapsocket.net_packet = {}

function rapsocket.create(port, handle)
  local n = {}
  setmetatable(n, rapsocket)
  n.handle = handle
  n.modhandle = socket.create(port, modem_handler(n, src, port, message))
end

--functions for formatting, serializing and unserializing NET packets
function rapsocket.net_packet.serialize(from, to, content)
  local p = {pa, to, content}
end

function rapsocket.net_packet.unserialize(str)

end

--this is where modem-level packets are interpreted as rap-level messages
--should return src, port and message of the rap packet
local function modem_handler(self, src, port, message)
  --TODO
  local src = nil, port = nil, message = nil
  return src, port, message
end

--this is where rap-level messages are encapsulated as modem-socket level packets
-- addr (rap), port (number), [content (string), from (rap)]
function rapsocket:send(addr, port, content, from)
  --TODO
  local m = rapsocket.net_packet.serialize()
end

function rapsocket:handle(src, port, message) error("unimplemented net handler") end

return rapsocket

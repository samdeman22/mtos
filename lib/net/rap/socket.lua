--          MT RAP SOCKET API
-- built on top of modhandle, RAP and NET for easy rap-level networking

local serial = require("serialization")
local net = require("net/ntable")
local rap = require("net/rap")
local socket = require("net/socket")
local socket = {}
socket.net_packet = {}

function socket.create(port, handle)
  local n = {}
  setmetatable(n, socket)
  n.handle = handle
  n.modhandle = socket.create(port, modem_handler(n, src, port, message))
end

--functions for formatting, serializing and unserializing NET packets
function socket.net_packet.serialize(from, to, content)
  local p = {pa, to, content}
end

function socket.net_packet.unserialize(str)

end

--this is where net-socket level packets are interpreted as rap-level messages
--should return src, port and message of the rap packet
local function modem_handler(self, src, port, message)
  --TODO
  local src = nil, port = nil, message = nil
  return src, port, message
end

--this is where rap-level messages are encapsulated as net-socket level packets
-- addr (rap), port (number), [content (string), from (rap)]
function socket:send(addr, port, content, from)
  --TODO
  local m = socket.net_packet.serialize()
end

function socket:handle(src, port, message) error("unimplemented net handler") end

return socket

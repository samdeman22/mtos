--          PACKET API
--

local serial = require("serialization")

local packet = {}
packet.__index = packet

function packet.create(from, path, content, protocol)
  local pak = {}
  pak.from = from
  pak.path = path
  pak.content = content
  --optional protocol
  pak.protocol = protocol
  return pak
end

--(de)serialization wrappers, cos why not...
function packet.deserialize(input)
  return serial.unserialize(input)
end

function packet:serialize()
  local t = {}
  t.from = self.from
  t.path = self.path
  t.content = self.content
  t.protocol = self.protocol
  return serial.serialize(t)
end

return packet
--          PACKET API
-- Functions for the forming of packet tables, with convenient (un)serialization

local serial = require("serialization")

local packet = {}
packet.__index = packet

function packet.create(src, dst, content)
  local pak = {}
  pak.from = src
  pak.dst = dst
  pak.content = content
  return pak
end

--(de)serialization wrappers, cos why not...
function packet.deserialize(input)
  return serial.unserialize(input)
end

function packet:serialize()
  local t = {}
  t.from = self.src
  t.dst = self.dst
  t.content = self.content
  return serial.serialize(t)
end

return packet
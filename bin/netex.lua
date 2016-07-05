--          NETEX BACKGROUND DAEMON
--

--imports
local std = require("std")
local ntable = require("net/ntable")
local nhandle = require("net/nhandle")
local coroutine = require("coroutine")

--recieving messages on the NET port
local nh = nhandle.create(std.ports.NET, function(self, src, port, message) --on client handle
  if message then
    local packet = serial.serialize(message)
    if packet then
      --update local NET-table with information given from responder this will
      --be prone to smurf attacks if an upper level of heirarchical network is physically hacked
      if packet.ex and not ntable.get("ex") then ntable.update("ex", packet.ex) end
    else -- failed serialization of packet
      error("could not serialize NET-TABLE response from "..packet.from)
    end
  else -- no message from src
    print("malformed packet from "..src.."; client handler on port "..port)
  end
end)

-- other processes can pause/resume netme listening by setting the flag
_G["FLAG"].NETEX_LISTEN = true

--main process
while true do
  if not nh.accepting and _G["FLAG"].NETEX_LISTEN then
    local cr = coroutine.create(function() nh:accept(); coroutine.yield() end)
    coroutine.resume(cr)
  else
    --will stop the nethandle and cause the coroutine to yield
    nh.accepting = false
  end
end

--          MT NETHANDLE API--
-- built on top of modem for slightly easier networking

local component = require("component")
local event = require("event")
local serial = require("serialization")
local packet = require("net/packet")

local nhandle = {}

--constructor
function nhandle.create(port, handle)
  local nh = {}
  print("creating nethandler on ".. port)
  setmetatable(nh, nhandle)
  nh.accepting = false
  nh.port = port
  nh.handle = handle
  nh.modem = component.modem
  return nh
end

--should be overriden by implementation to do as desired
function nhandle:handle(src, port, message) error("unimplemented handler") end

function nhandle:send(addr, port, ...)
  self.modem.send(addr, port, arg)
end

--start the accepting loop, will call the provided handler on the client packet
--will end when self.accepting is set to false
function nhandle:accept()
  self.accepting = true
  self.modem.open(self.port)
  while self.accepting do
    --print("waiting for clients")
    --blocking call, wait for client messages
    local event, src, port, _, message = event.pull("modem_message")
    --start a coroutine to handle the client
    local cr = coroutine.create(function()
      self:handle(src, port, message)
      coroutine.yield()
    end)
    coroutine.resume(cr)
  end
end

function nhandle:accept_async()
  self.accepting = true
  self.modem.open(self.port)
  event.listen("modem_message", function(_, src, port, _, message)
    self:handle(src, port, message)
  end)
end

nhandle.__index = nhandle
return nhandle

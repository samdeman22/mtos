--          MT NET SOCKET API
-- built on top of modem for slightly easier networking

local component = require("component")
local event = require("event")
local serial = require("serialization")

local socket = {}

--constructor
function socket.create(port, handle)
  local s = {}
  setmetatable(s, nhandle)
  s.accepting = false
  s.port = port
  s.handle = handle
  s.callback = function (_, src, port, _, message) nh.handle(src,port,message) end
  s.modem = component.modem
  return s
end

--should be overriden by implementation to do as desired
function socket:handle(src, port, message) error("unimplemented socket handler") end

function socket:send(addr, port, ...)
  self.modem.send(addr, port, arg)
end

--start the accepting loop, will call the provided handler on the client packet
--will end when self.accepting is set to false
function socket:accept_sync(timeout)
  self.accepting = true
  self.modem.open(self.port)
  while self.accepting do
    --print("waiting for clients")
    --blocking call, wait for client messages
    if timeout then
      local event, src, port, _, message = event.pull(timeout, "modem_message")
      self:handle(src, port, message)
    else
      local event, src, port, _, message = event.pull("modem_message")
      self:handle(src, port, message)
    end
  end
end

function socket:accept_async()
  self.accepting = true
  self.modem.open(self.port)
  --asynchronously apply self:handle to incoming messages
  event.listen("modem_message", self:callback)
end

function socket:close_async()
  event.ignore("modem_message", self:callback)
end

socket.__index = socket
return socket

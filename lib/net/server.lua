--          MT NET SERVER SOCKET API
-- allows the serving of NET packets: the accepting of connections from NET sockets;
-- and the sending back of data

local component = require("component")
local event = require("event")
local serial = require("serialization")
local std = require("std").net.server
local util_values = require("util/values")

local server = {}

function server.create(port, handle)
  local s = {}
  setmetatable(s, server)
  s.stop = false
  s.port = port
  s.handle = handle
  --bind the callback to the implementation defined handler
  s.callback = function (_, src, port, _, message) s.handle(src,port,message) end
  s.modem = component.modem
  return s
end

--should be overriden by implementation to do as desired
function server:handle(src, port, message) error("unimplemented socket handler in server "..self) end

function server:send(addr, port, ...)
  self.modem.send(addr, port, arg)
end

--start the accepting loop, will call the provided handler on the client packet
--will end when self.accepting is set to false
function server:accept_sync(timeout)
  local timeout = timeout or util_values.int_max
  self.stop = false
  self.modem.open(self.port)
  while not self.stop do
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

function server:accept_async()
  self.accepting = true
  self.modem.open(self.port)
  --asynchronously apply self:handle to incoming messages
  event.listen("modem_message", self:callback)
end

--unregister the event listener for modem_message on this callback
--only this server should have the self:callback reference, others' callback hash
--should be different.
function server:close_async()
  event.ignore("modem_message", self:callback)
end

return server

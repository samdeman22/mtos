--          MT NET SERVER SOCKET API
-- allows the serving of NET packets: the accepting of connections from NET sockets;
-- and the sending back of data

local component = require("component")
local event = require("event")
local serial = require("serialization")

local server = {}
server.__index = server

function server.create(port, handle)
  local s = setmetatable({}, server)
  s.port = port
  s.handle = handle
  --bind the callback to the implementation defined handler
  s._callback = function (_, _, src, port, _, message) s:handle(src,port,message) end
  s.modem = component.modem
  return s
end

--should be overriden by implementation to do as desired
function server:handle(src, port, message) error("unimplemented socket handler in server "..self) end

function server:send(addr, port, ...)
  self.modem.send(addr, port, arg)
end

--start listening; will call the provided handler on the client message
--will end when once a client message has been dealt with
function server:accept_sync(timeout)
  --blocking call, wait for client messages
  if timeout then
    local event, _, src, port, _, message = event.pull(timeout, "modem_message")
    if event then --otherwise timeout finished...
      print(message.." from "..src.." on port "..port)
      self:handle(src, port, message)
    end
  else
    local _, _, src, port, _, message = event.pull("modem_message")
    --print(message.." from "..src.." on port "..port)
    self:handle(src, port, message)
  end
end

function server:accept_async()
  --asynchronously apply self:handle to incoming messages
  event.listen("modem_message", self._callback)
end

--unregister the event listener for modem_message on this callback
--only this server should have the self:callback reference, others' callback hash
--should be different.
function server:stop_async()
  event.ignore("modem_message", self._callback)
end

--open port for server to listen on
function server:open()
  return self.modem.open(self.port)
end

--close port for server to listen on
function server:close()
  return self.modem.close(self.port)
end

return server

--          MT NET SOCKET API
-- allows for the connection to NET server sockets, as well as sending requests
-- and recieving data

local component = require("component")
local event = require("event")
local serial = require("serialization")
local server = require("net/server")

local socket = {}

--constructor
function socket.create(addr, port, handle)
  local s = {}
  setmetatable(s, nhandle)
  s.port = port
  s.handle = handle
  s.modem = component.modem
  return s
end

--should be overriden by implementation to do as desired
function socket:handle(src, port, message) error("unimplemented server handler in socket "..self) end

function socket:send(addr, port, ...)
  self.modem.send(addr, port, arg)
  srv = server.create(port, handle)
  srv:accept_sync()
end

socket.__index = socket
return socket

--          MT NET SOCKET API
-- allows for the connection to NET server sockets, as well as sending requests
-- and recieving data

local component = require("component")
local serial = require("serialization")
local server = require("net/server")

local socket = {}

--constructor
function socket.create(addr, port, handle)
  local s = {}
  setmetatable(s, socket)
  s.addr = addr
  s.port = port
  s.handle = function(self, src, port, msg)
    ser = serial.unserialize(msg)
    assert(handle and typeof(handle) == "function", "expected a function of (self, src, port, message) for handle, got "..tostring(handle))
    handle(self, ser and ser or msg)
  end
  assert(component.modem, "no modem found to create socket!")
  s.modem = component.modem
  return s
end

--send the serialized contents of extra arguments and wait for response
--the response is dealt with by the defined handler
function socket:send(...)
  self.modem.send(self.addr, self.port, serial.serialize(arg))
  srv = server.create(port, function(slf, src, port, msg) self.handle(src, port, msg) end)
  srv:accept_sync()
end

--send the serialized contents of extra arguments and forget
function socket:fire(...)
  self.modem.send(self.addr, self.port, serial.serialize(arg))
end

--open port for socket to listen on
function socket:open()
  return self.modem.open(self.port)
end

--close port for socket to listen on
function socket:close()
  return self.modem.close(self.port)
end

socket.__index = socket
return socket

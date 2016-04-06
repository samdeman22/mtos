          --MT NETHANDLE API--
--Specially for more easily handling messages over modem
--

local component = require("component")
local event = require("event")
local serial = require("serialization")
local packet = require("packet")

local nhandle = {}
nhandle.__index = nhandle

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

function nhandle:send(addr, port, message)
  local out = nil
  if type(message) == "table" then
    out = serial.serialize(message)
  elseif type(message) == "string" then
    out = message
  else
    error("expected either a string or table for message in nhandle.send")
  end
  
  if _G["NET"]
  self.modem.send()
end

--should be overriden by implementation to do as desired
function nhandle:handle(remote, port, message, remotePublic) print("unimplemented handler") end

--start the accepting loop, will call the provided handler on the client packet
--will end when self.accepting is set to false
function nhandle:accept()

  self.accepting = true
  self.modem.open(self.port)
  print("nethandler: accepting on "..self.port)
 
  while self.accepting do
    
    print("waiting for clients")
    --blocking call, wait for client messages
    local event, remote, port, _, message, remotePublic= event.pull("modem_message")
    
    --start a coroutine to handle the client
    local cr = coroutine.create(function() 
      self:handle(remote, port, message, remotePublic)
      coroutine.yield()
    end)
    
    coroutine.resume(cr)

  end
end

return nhandle
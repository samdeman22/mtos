--          NETME BACKGROUND DAEMON
--

--imports
local std = require("std")
local ntable = require("net/table")
local nhandle = require("net/handle")
local coroutine = require("coroutine")

--recieving messages on the NET port
local nh = nhandle.create(std.ports.NET, function(self, src, port, message) --on client handle
  if message then
    local packet = serial.serialize(message)
    if packet then
      --update local NET-table with information given from responder this will
      --be prone to smurf attacks if an upper level of heirarchical network is physically hacked
      for k, v in pairs(packet.table) do
        --the values of table[127], table[331] and table[316] could be edited, but they should *not* be used
        --use ntable.get("ex"), ntable.update("ex", value) etc. instead
        if (type(k) == "number" and k >= 0 and k <= 675 and k ~= 127 and k ~= 331 and k~= 316) then
          ntable.update(k, v)
        end
      end
    else -- failed serialization of packet
      error("could not serialize NET-TABLE response from "..packet.from)
    end
  else -- no message from src
    print("malformed packet from "..src.."; client handler on port "..port)
  end
end)

local running = false

--define main running routine
local function main
  ntable.load()
  while running do
    if not nh.accepting and _G["FLAG"].NETME_LISTEN then
      nh:accept();
    else
      --will stop the nethandle and cause the coroutine to yield
      nh.accepting = false
    end
  end
  ntable.save()
  coroutine.yield()
end

local cr = coroutine.create(main)

--global functions for usage in RC
function start()
  _G["FLAG"].NETME_LISTEN = true
  running = true
  coroutine.resume(cr)
end

--pause listening but keep
function pause()
  _G["FLAG"].NETME_LISTEN = false
end

function continue()
  _G["FLAG"].NETME_LISTEN = true
end

function stop()
  _G["FLAG"].NETME_LISTEN = false
  running = false
end

function save()
  ntable.save()
end

function flush()
  ntable.flush()
end

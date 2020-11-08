local thread = require('thread')
local modem = require('modem')
local event = require('event')

local rpc = {}

-- Ports
local rpc.PORT_CLIENT = 9501
local rpc.PORT_SERVER = 9500

-- Commands
local rpc.CMD_DISCOVER = 0 -- discover client name
local rpc.CMD_EVAL = 1 -- execule code

-- Server answers
local rpc.RPL_CMD_RECIEVED = 0 -- command recieved
local rpc.RPL_CMD_RESULT = 1 -- command execution result code
local rpc.RPL_CMD_DATA = 2 -- command data

rpc.clientOpen = function()
    event.listen('modem_message', rpc.clientHandler)
    return modem.isOpen(rpc.PORT_CLIENT) or modem.open(rpc.PORT_CLIENT)
end

rpc.call = function(cmd, data)
    modem.broadcast(rpc.PORT_SERVER, math.random(0,65535), cmd, data)
end

rpc.clientHandler = function(receiverAddress, senderAddress, port, distance, data)
    print(recieverAddress .. ' ' .. senderAddress)
end

return rpc

local thread = require('thread')
local component = require('component')
local event = require('event')

local modem = component.modem

local rpc = {}

-- Ports
rpc.PORT_CLIENT = 9501
rpc.PORT_SERVER = 9500

-- Commands
rpc.CMD_DISCOVER = 0 -- discover client name
rpc.CMD_EVAL = 1 -- execule code

-- Server answers
rpc.RPL_CMD_RECIEVED = 0 -- command recieved
rpc.RPL_CMD_RESULT = 1 -- command execution result code
rpc.RPL_CMD_DATA = 2 -- command data

function rpc.clientOpen()
    event.listen('modem_message', rpc.clientHandler)
    return modem.isOpen(rpc.PORT_CLIENT) or modem.open(rpc.PORT_CLIENT)
end

function rpc.call(cmd, data)
    modem.broadcast(rpc.PORT_SERVER, math.random(0,65535), cmd, data)
end

function rpc.clientHandler(receiverAddress, senderAddress, port, distance, data)
    print(recieverAddress .. ' ' .. senderAddress)
end

return rpc

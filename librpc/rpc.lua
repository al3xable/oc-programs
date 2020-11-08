local thread = require('thread')
local component = require('component')
local event = require('event')

local modem = component.modem

local rpc = {}

rpc.answers = {}

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
    rpc.clientPuller = thread.create(function()
        local receiverAddress, senderAddress, port, distance, cmdId, code, data = event.pull('modem_message')
        rpc.answers[cmdId] = 123
    end)
    return modem.isOpen(rpc.PORT_CLIENT) or modem.open(rpc.PORT_CLIENT)
end

function rpc.call(cmd, data, timeout)
    if timeout == nil then
        timeout = 30
    end
    local cmdId = math.random(0,65535)

    print(cmdId)

    modem.broadcast(rpc.PORT_SERVER, cmdId, cmd, data)
    while rpc.answers[cmdId] == nil do
        print(rpc.answers[cmdId])
        os.sleep(0.1)
    end
    print(rpc.answers[cmdId])
end

function rpc.clientHandler(receiverAddress, senderAddress, port, distance, cmdId, code, data)
    rpc.answers[cmdId] = 111
end

return rpc

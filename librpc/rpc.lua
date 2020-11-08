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
    return modem.isOpen(rpc.PORT_CLIENT) or modem.open(rpc.PORT_CLIENT)
end

function rpc.call(cmd, data, timeout)
    if timeout == nil then
        timeout = 30
    end
    --local cmdId = math.random(0,65535)
    local cmdId = 255
    local resultPong, resultCode, resultData = false, nil, nil

    print(cmdId)

    local puller = thread.create(function()
        while true do
            local _, receiverAddress, senderAddress, port, _, eCmdId, eCode, eData = event.pull('modem_message')
            if eCmdId == cmdId then
                if eCode == rpc.RPL_CMD_RECIEVED then
                    resultPong = true
                elseif eCode == rpc.RPL_CMD_RESULT then
                    resultCode = eData
                elseif eCode == rpc.RPL_CMD_DATA then
                    if resultData == nil then
                        resultData = eData
                    else
                        resultData = resultData .. eData
                    end
                end
            end
        end
    end)

    modem.broadcast(rpc.PORT_SERVER, cmdId, cmd, data)

    while resultCode == nil do
        print(tostring(resultPong) .. '-' .. tostring(resultCode) .. '-' .. tostring(resultData))
        os.sleep(1)
    end
    return
end

return rpc

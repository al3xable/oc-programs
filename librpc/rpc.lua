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

function rpc.callBroadcast(cmd, data, timeout)
    if timeout == nil then
        timeout = 10
    end
    local cmdId = math.random(0,65535)
    local resultPong, resultCode, resultData = false, nil, nil
    local results = {}

    local puller = thread.create(function()
        while true do
            local _, receiverAddress, senderAddress, port, _, eCmdId, eCode, eData = event.pull('modem_message')
            if port == rpc.PORT_CLIENT and eCmdId == cmdId then
                if results[senderAddress] == nil then
                    results[senderAddress] = {
                        resultPong = false,
                        resultCode = nil,
                        resultData = nil
                    }
                end

                if eCode == rpc.RPL_CMD_RECIEVED then
                    results[senderAddress].resultPong = true
                elseif eCode == rpc.RPL_CMD_RESULT then
                    results[senderAddress].resultCode = eData
                elseif eCode == rpc.RPL_CMD_DATA then
                    if results[senderAddress].resultData == nil then
                        results[senderAddress].resultData = eData
                    else
                        results[senderAddress].resultData = results[senderAddress].resultData .. eData
                    end
                end
            end
        end
    end)

    modem.broadcast(rpc.PORT_SERVER, cmdId, cmd, data)
    os.sleep(timeout)
    puller:kill()

    for key,value in results do
        results[key].resultData = table.concat(results[key].resultData, '')
    end

    return cmdId, results
end

function rpc.call(address, cmd, data, timeout)
    if timeout == nil then
        timeout = 30
    end
    local cmdId = math.random(0,65535)
    local timeoutClk = 0
    local resultPong, resultCode, resultData = false, nil, nil

    local puller = thread.create(function()
        while true do
            local _, receiverAddress, senderAddress, port, _, eCmdId, eCode, eChunk, eData = event.pull('modem_message')
            if port == rpc.PORT_CLIENT and eCmdId == cmdId then
                if eCode == rpc.RPL_CMD_RECIEVED then
                    resultPong = true
                elseif eCode == rpc.RPL_CMD_RESULT then
                    resultCode = eData
                elseif eCode == rpc.RPL_CMD_DATA then
                    if resultData == nil then
                        resultData = {}
                    end
                    resultData[eChunk] = eData
                end
            end
        end
    end)

    modem.send(address, rpc.PORT_SERVER, cmdId, cmd, data)

    while resultCode == nil do
        if timeoutClk >= timeout then
            break
        end

        local sleep = 0.1
        os.sleep(sleep)
        timeoutClk = timeoutClk + sleep
    end
    puller:kill()

    resultData = table.concat(resultData, '')
    return cmdId, resultPong, resultCode, resultData
end

return rpc

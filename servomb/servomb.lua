local component = require("component")
local sides = require("sides")
local term = require("term")

local rs = component.redstone

function mb2time(mb)
  if mb <= 300 then
    return 0.05
  end

  local servoTime = 0.05*((mb-300)/60)

  return math.ceil(servoTime*20)/20 + 0.05
end

function time2mb(time)
  if time <= 0.05 then
    return 300
  end
  return 300+(time-0.05)*1200
end

term.write('Please, enter mB: ')
local sas = tonumber(term.read())

local time = mb2time(sas)

term.write('Will be transfered: ' .. time2mb(time) .. '\n')
term.write('Time: ' .. time .. '\n')
term.write('Continue? [Y/N]: ')


--local yn = term.read()
--if yn ~= 'y' and yn ~= 'Y' then
--  return 0
--end

rs.setOutput(sides.south, 15)
os.sleep(time-0.04)
rs.setOutput(sides.south, 0)

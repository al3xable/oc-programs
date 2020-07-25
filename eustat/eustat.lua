local component = require('component')
local term = require('term')
local text = require('text')
local sides = require('sides')

local SIDE_DIRECT_POWER = sides.right
local SIDE_MFSU_OUTPUT = sides.left
local SIDE_MFSU_INPUT = sides.front
local SIDE_ENERGY_INPUT = sides.back

-- Number format
local function numformat(number)
    if number < 0 or number == 0 or not number then
        return nil
    elseif number > 0 and number < 1000 then 
        return math.ceil(number * 0.01) * 0.1 .. 'K'
    elseif number >= 1000000 and number < 1000000000 then
        return math.ceil(number * 0.00001) * 0.1 .. 'M'
    elseif number >= 1000000000 then 
        return math.ceil(number * 0.00000001) * 0.1 .. 'G'
    else
        return tostring(number)
    end
end

-- Switch set value
local function switchSet(side, mode)
  if mode then
    component.redstone.setOutput(side, 0)
  else
    component.redstone.setOutput(side, 15)
  end
end

-- Switch get value
local function switchGet(side)
  component.redstone.setOutput(side, 0)
  return component.redstone.getInput(side) < 1
end

while true do
  term.clear()

  local totalCapacity, totalStored = 0, 0

  term.write('--------- MFSU ENERGY ---------\n')

  for address, name in component.list('mfsu', true) do
    local mfsu = component.proxy(address)

    local capacity = math.ceil(mfsu.getEUCapacity())
    local stored = math.ceil(mfsu.getEUStored())
    local percent = math.ceil((stored/capacity)*100)

    totalCapacity = totalCapacity+capacity
    totalStored = totalStored+stored

    term.write(text.padRight(numformat(stored), 27) .. text.padLeft(percent .. '%', 4) .. '\n')
  end

  local totalPercent = math.ceil((totalStored/totalCapacity)*100)

  term.write('------------ total ------------\n')
  term.write(text.padRight(numformat(totalStored) .. ' / ' .. numformat(totalCapacity), 27) .. text.padLeft(totalPercent .. '%', 4) .. '\n')

  switchSet(SIDE_MFSU_INPUT, true)
  
  if totalPercent > 99 then
    switchSet(SIDE_DIRECT_POWER, true)
    if switchGet(SIDE_ENERGY_INPUT) then
      switchSet(SIDE_MFSU_OUTPUT, false)
    else
      switchSet(SIDE_MFSU_OUTPUT, true)
    end
  else
    switchSet(SIDE_DIRECT_POWER, false)
    switchSet(SIDE_MFSU_OUTPUT, true)
  end

  os.sleep(0.5)
end

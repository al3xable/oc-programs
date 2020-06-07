local component = require('component')
local term = require('term')
local gpu = component.gpu

-- Load screens list
local screens = {}
for address, componentType in component.list('screen') do 
    table.insert(screens, component.proxy(address))
end

-- Select screen
term.write('Current screen: ' .. term.screen() .. '\n')
term.write('Please, select screen:\n')
for i = 1, #screens do
  term.write(i .. ': ' .. screens[i].address)
  if screens[i].address == term.screen() then
    term.write(' (current)')
  end
  term.write('\n')
end
local screenId = tonumber(term.read())
local screen = screens[screenId]


term.clear()

gpu.bind(screen.address, true)
component.setPrimary('keyboard', screen.getKeyboards()[1])
local maxW, maxH = gpu.maxResolution()
gpu.setResolution(maxW, maxH)

term.clear()
term.write('Selected screen: ' .. screen.address .. '\n')


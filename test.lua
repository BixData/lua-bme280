print('Begin test')

local bme280 = require 'bme280'
local periphery = require 'periphery'

-- ============================================================================
-- Mini test framework
-- ============================================================================

local failures = 0

local function assertEquals(expected,actual,message)
  message = message or string.format('Expected %s but got %s', tostring(expected), tostring(actual))
  assert(actual==expected, message)
end

local function it(message, testFn)
  local status, err =  pcall(testFn)
  if status then
    print(string.format('✓ %s', message))
  else
    print(string.format('✖ %s', message))
    print(string.format('  FAILED: %s', err))
    failures = failures + 1
  end
end


-- ============================================================================
-- bme280 module
-- ============================================================================

it('readSensorID', function()
  local I2C = periphery.I2C
  local i2c = I2C('/dev/i2c-1')
  local sensorID = bme280.readSensorID(i2c)
  assertEquals(0x60, sensorID)
end) 

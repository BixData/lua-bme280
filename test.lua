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

it('getOversamplingRation', function()
  assertEquals(1, bme280.getOversamplingRation(bme280.AccuracyMode.ULTRA_LOW))
  assertEquals(2, bme280.getOversamplingRation(bme280.AccuracyMode.LOW))
  assertEquals(3, bme280.getOversamplingRation(bme280.AccuracyMode.STANDARD))
  assertEquals(4, bme280.getOversamplingRation(bme280.AccuracyMode.HIGH))
  assertEquals(5, bme280.getOversamplingRation(bme280.AccuracyMode.ULTRA_HIGH))
end)
 
it('readSensorID', function()
  local I2C = periphery.I2C
  local i2c = I2C('/dev/i2c-1')
  local sensorID = bme280.readSensorID(i2c)
  assertEquals(0x60, sensorID)
end) 
 
it('readUncompensatedTemperature', function()
  local I2C = periphery.I2C
  local i2c = I2C('/dev/i2c-1')
  local temp = bme280.readUncompensatedTemperature(i2c, bme280.AccuracyMode.ULTRA_LOW)
  assertEquals(true, temp > 0)
end) 

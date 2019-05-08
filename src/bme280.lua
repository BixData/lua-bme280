local bit32 = require 'bit32'
local I2C = require 'periphery'.I2C

local M = {
  AccuracyMode = {
    ULTRA_LOW  = 0, --  x1 sample
    LOW        = 1, --  x2 samples
    STANDARD   = 2, --  x4 samples
    HIGH       = 3, --  x8 samples
    ULTRA_HIGH = 4  -- x16 samples
  },
  
  DEVICE = 0x76,
  
  -- memory map
  ID_REG                = 0xD0,
  RESET                 = 0xE0,
  CTRL_HUM              = 0xF2,
  STATUS                = 0xF3,
  CTRL_MEAS             = 0xF4,
  CONFIG                = 0xF5, -- TODO: support IIR filter settings
  TEMP_OUT_MSB_LSB_XLSB = 0xFA
}

function M.getOversamplingRation(accuracyMode)
  return accuracyMode + 1
end

function M.readSensorID(i2c)
  local msgs = {{M.ID_REG}, {0x00, flags=I2C.I2C_M_RD}}
  i2c:transfer(M.DEVICE, msgs)
  local id = msgs[2][1]
  return id
end

function M.readUncompensatedTemperature(i2c, accuracyMode)
  local power = 1 -- forced mode
  local osrt = M.getOversamplingRation(accuracyMode)
  local msgs = {{M.CTRL_MEAS, bit32.bor(power, bit32.lshift(osrt,5))}}
  i2c:transfer(M.DEVICE, msgs)
  msgs = {{M.TEMP_OUT_MSB_LSB_XLSB}, {0x00, 0x00, 0x00, flags=I2C.I2C_M_RD}}
  i2c:transfer(M.DEVICE, msgs)
  local ut = bit32.lshift(msgs[2][1],12) + bit32.lshift(msgs[2][2],4) + bit32.rshift(bit32.band(msgs[2][3],0xf0),4) 
  return ut
end

return M

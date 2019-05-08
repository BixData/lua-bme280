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
  ID_REG = 0xd0
}

M.readSensorID = function(i2c)
  local msgs = {{M.ID_REG}, {0x00, flags=I2C.I2C_M_RD}}
  i2c:transfer(M.DEVICE, msgs)
  local id = msgs[2][1]
  return id
end

return M

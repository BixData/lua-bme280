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
  PRESS_OUT_MSB_LSB_XLSB= 0xF7, -- 3-byte
  TEMP_OUT_MSB_LSB_XLSB = 0xFA, -- 3-byte
  HUM_OUT_MSB_LSB       = 0xFD, -- 3-byte
  
  -- memory map: compensation register's blocks
  COEF_PART1_START = 0x88,
  COEF_PART2_START = 0xA1,
  COEF_PART3_START = 0xE1
}

function M.getOversamplingRation(accuracyMode)
  return accuracyMode + 1
end

-- read compensation coefficients, unique for each sensor
function M.readCoefficients(i2c)
  local msgs = {
    {M.COEF_PART1_START},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, flags=I2C.I2C_M_RD}
  }
  i2c:transfer(M.DEVICE, msgs)
  local coef1 = msgs[2]

--  _, err = i2c.WriteBytes([]byte{BME280_COEF_PART1_START})
--  var coef2 [BME280_COEF_PART2_BYTES]byte
--  err = readDataToStruct(i2c, BME280_COEF_PART1_BYTES,
--    binary.LittleEndian, &coef1)

--  _, err = i2c.WriteBytes([]byte{BME280_COEF_PART3_START})
--  var coef3 [BME280_COEF_PART3_BYTES]byte
--  err = readDataToStruct(i2c, BME280_COEF_PART3_BYTES,
--    binary.LittleEndian, &coef3)
  return {
    dig_T1 = M.readUShort(coef1[ 1], coef1[ 2]),
    dig_T2 = M.readShort (coef1[ 3], coef1[ 4]),
    dig_T3 = M.readShort (coef1[ 5], coef1[ 6]),
    
    dig_P1 = M.readUShort(coef1[ 7], coef1[ 8]),
    dig_P2 = M.readShort (coef1[ 9], coef1[10]),
    dig_P3 = M.readShort (coef1[11], coef1[12]),
    dig_P4 = M.readShort (coef1[13], coef1[14]),
    dig_P5 = M.readShort (coef1[15], coef1[16]),
    dig_P6 = M.readShort (coef1[17], coef1[18]),
    dig_P7 = M.readShort (coef1[19], coef1[20]),
    dig_P8 = M.readShort (coef1[21], coef1[22]),
    dig_P9 = M.readShort (coef1[23], coef1[24])
  }
end

function M.readSensorID(i2c)
  local msgs = {{M.ID_REG}, {0x00, flags=I2C.I2C_M_RD}}
  i2c:transfer(M.DEVICE, msgs)
  local id = msgs[2][1]
  return id
end

function M.readShort(lsb, msb)
  local val = lsb + msb * 256
  if val >= 32768 then val = val - 65536 end
  return val
end

function M.readUShort(lsb, msb)
  return lsb + msb * 256
end

-- reads and calculates temperature in C
function M.readTemperatureC(i2c, accuracyMode, coeff)
  local ut, err = M.readUncompensatedTemperature(i2c, accuracyMode)
  if err ~= nil then return 0, err end
  
  local var1 = bit32.rshift(
    (bit32.rshift(ut,3) - bit32.lshift(coeff.dig_T1,1)) * coeff.dig_T2,
    11
  )
  local var2 = bit32.rshift(
    bit32.rshift((bit32.rshift(ut,4) - coeff.dig_T1) * (bit32.rshift(ut,4) - coeff.dig_T1), 12) * coeff.dig_T3,
    14
  )
  local tFine = var1 + var2
  local t = bit32.rshift((tFine*5 + 128), 8) / 100
  return t, nil
end

function M.readUncompensatedTemperature(i2c, accuracyMode)
  local power = 1 -- forced mode
  local osrt = M.getOversamplingRation(accuracyMode)
  local msgs = {{M.CTRL_MEAS, bit32.bor(power, bit32.lshift(osrt,5))}}
  i2c:transfer(M.DEVICE, msgs)
  msgs = {{M.TEMP_OUT_MSB_LSB_XLSB}, {0x00, 0x00, 0x00, flags=I2C.I2C_M_RD}}
  i2c:transfer(M.DEVICE, msgs)
  local ut = bit32.lshift(msgs[2][1],12) + bit32.lshift(msgs[2][2],4) + bit32.rshift(bit32.band(msgs[2][3],0xf0),4) 
  return ut, nil
end

return M

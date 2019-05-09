<img align="right" src="bme280.png" width="70">

# BME280 Lua driver

A [lua-periphery](https://github.com/vsergeev/lua-periphery) based driver for the Bosch Sensortec BME280 temperature, atmospheric pressure, and humidity sensor.

This is a port of Denis Dyakov's [go-bsbmp](https://github.com/d2r2/go-bsbmp) driver (MIT License), with portions contributed by Iron Heart Consulting LLC.

## Usage

### Reading Temperature

```lua
local bme280 = require 'bme280'
local periphery = require 'periphery'

local i2c = periphery.I2C('/dev/i2c-1')
local coeff = bme280.readCoefficients(i2c)
local tempC = bme280.readTemperatureC(i2c, bme280.AccuracyMode.STANDARD, coeff)

print(string.format('Temperature: %3.2f C', tempC))
```

Sample output:

```
Temperature: 27.92 C
```

package = "bme280"
version = "0.1.0-0"
source = {
   url = "https://github.com/BixData/lua-bme280/archive/0.1.0-0.tar.gz",
   dir = "bme280-0.1.0-0"
}
description = {
   summary = "BME280 I²C Atmospheric Sensor driver",
   detailed = [[
     BME280 is a precision sensor for temperature, humidity, and barometric pressure.
     It features a very accurate pressure sensor, and an associated temperature sensor
     which helps calibrate pressure readings.
   ]],
   homepage = "https://github.com/BixData/lua-bme280",
   maintainer = "David Rauschenbach",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "lua-periphery >= 1.1.1"
}
build = {
   type = "builtin",
   modules = {
      stuart = "src/bme280.lua"
   }
}
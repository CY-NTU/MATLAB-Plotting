# -*- coding: utf-8 -*-
"""
Created on Wed Jul 12 14:05:59 2023

@author: 32062
"""

import time
import board
import busio
import qwiic
import adafruit_tca9548a
from adafruit_lsm6ds.lsm6dsox import LSM6DSOX as LSM6DS
from adafruit_lsm6ds import AccelRange, GyroRange
from adafruit_lsm6ds import Rate as accelRate
from adafruit_lis3mdl import LIS3MDL, Range
from adafruit_lis3mdl import Rate as magRate
from adafruit_lsm6ds.ism330dhcx import ISM330DHCX
import minimalmodbus
import csv
from datetime import datetime

dic = '/home/pi/Angle/'
no = 'test1'

i2c = busio.I2C(board.SCL, board.SDA)  # uses board.SCL and board.SDA
mux = qwiic.QwiicTCA9548A()
tca = adafruit_tca9548a.TCA9548A(i2c)
#sensor_up = LSM6DS(tca[0])
#sensor_mid = LSM6DS(tca[1])
#sensor_low = LSM6DS(tca[2])
#mag_up = LIS3MDL(tca[0])
#mag_mid = LIS3MDL(tca[1])
#mag_low = LIS3MDL(tca[2])
sensor_up = ISM330DHCX(tca[0])
sensor_mid = ISM330DHCX(tca[1])
sensor_low = ISM330DHCX(tca[2])

mux.enable_channels([0,1,2])
mux.list_channels()

# Setup of sensors and relay
sensor_up.accelerometer_data_rate = accelRate.RATE_416_HZ
sensor_mid.accelerometer_data_rate = accelRate.RATE_416_HZ
sensor_low.accelerometer_data_rate = accelRate.RATE_416_HZ
sensor_up.gyro_data_rate = accelRate.RATE_416_HZ
sensor_mid.gyro_data_rate = accelRate.RATE_416_HZ
sensor_low.gyro_data_rate = accelRate.RATE_416_HZ
instrument = minimalmodbus.Instrument("/dev/ttyUSB0", 0xFE)
instrument.serial.baudrate = 115200
instrument.clear_buffers_before_each_transaction = True

acc_up = sensor_up.acceleration
acc_mid = sensor_mid.acceleration
acc_low = sensor_low.acceleration
gyro_up = sensor_up.gyro
gyro_mid = sensor_mid.gyro
gyro_low = sensor_low.gyro

while True:

    # Get the current time
    t = time.monotonic()
    cur_datetime = datetime.now()
    sampletime = cur_datetime.strftime("%M:%S.%f")
    
    data_up = [[(sampletime),(acc_up),(gyro_up)]]
    data_mid = [[(sampletime),(acc_mid),(gyro_mid)]]
    data_low = [[(sampletime),(acc_low),(gyro_low)]]
    
    with open(dic + no + "_up.csv", 'a', newline='') as file:
        csvwriter = csv.writer(file, quoting=csv.QUOTE_NONNUMERIC)
        csvwriter.writerows(data_up)
        
    with open(dic + no + "_mid.csv", 'a', newline='') as file:
        csvwriter = csv.writer(file, quoting=csv.QUOTE_NONNUMERIC)
        csvwriter.writerows(data_mid)
        
    with open(dic + no + "_low.csv", 'a', newline='') as file:
        csvwriter = csv.writer(file, quoting=csv.QUOTE_NONNUMERIC)
        csvwriter.writerows(data_low)












# -*- coding: utf-8 -*-
"""
Created on Wed Jul 12 09:58:47 2023

@author: 32062
"""

import numpy as np
import tensorflow as tf
from tensorflow.keras import layers
import pandas as pd
import RPi.GPIO as GPIO
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

# Load the trained model
model = tf.keras.models.load_model('motion_model.h5')

# Define the class labels
class_labels = ['Regular', 'Irregular']

i2c = busio.I2C(board.SCL, board.SDA)  # uses board.SCL and board.SDA
mux = qwiic.QwiicTCA9548A()
tca = adafruit_tca9548a.TCA9548A(i2c)
# sensor_up = LSM6DS(tca[0])
# sensor_mid = LSM6DS(tca[1])
# sensor_low = LSM6DS(tca[2])
# mag_up = LIS3MDL(tca[0])
# mag_mid = LIS3MDL(tca[1])
# mag_low = LIS3MDL(tca[2])
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

# Define the data shape (number of samples, number of features)
data_shape = (1, 6)  # Adjust according to the number of accelerometer and gyroscope axes

# Create a buffer to store the real-time motion data
buffer_size = 100
data_buffer = np.zeros((buffer_size, data_shape[1]))

# Initialize the relay GPIO pin (replace with actual relay pin)
relay_pin = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(relay_pin, GPIO.OUT)

# Continuously read and analyze the motion data in real-time
while True:
    # Read the raw motion data from the IMU sensor
    accelerometer_data = sensor_up.acceleration + sensor_mid.acceleration + sensor_low.acceleration
    gyroscope_data = sensor_up.gyro + sensor_mid.gyro + sensor_low.gyro
    
    # Combine accelerometer and gyroscope data
    raw_data = np.concatenate((accelerometer_data, gyroscope_data), axis=0)

    # Update the data buffer
    data_buffer[:-1] = data_buffer[1:]
    data_buffer[-1] = raw_data

    # Reshape the data to match the model input shape
    input_data = data_buffer.reshape(data_shape)

    # Perform prediction on the input data
    prediction = model.predict(input_data)

    # Get the predicted label and confidence score
    predicted_label = class_labels[int(prediction[0][0])]
    confidence = prediction[0][0]

    # Provide feedback or take actions based on the prediction
    if confidence > 0.5:
        print(f"Detected motion: {predicted_label} (Confidence: {confidence})")
        if predicted_label == 'Regular':
            GPIO.output(relay_pin, GPIO.HIGH)  # Turn on the relay
        else:
            GPIO.output(relay_pin, GPIO.LOW)  # Turn off the relay
    else:
        GPIO.output(relay_pin, GPIO.LOW)  # Turn off the relay


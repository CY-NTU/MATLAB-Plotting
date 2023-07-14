# -*- coding: utf-8 -*-
"""
Created on Wed Jul 12 08:49:22 2023

@author: 32062
"""

import numpy as np
import tensorflow as tf
from tensorflow.keras import layers
import matplotlib.pyplot as plt
import pandas as pd

dir = 'E:/NTU/Research/OptiTrack/23.5.2/Dr Xiao/'

# Generate sample motion data (accelerometer and gyroscope readings)
fs = 250  # Sample rate (Hz)
t = np.arange(0, 1, 1/fs)  # Time vector
f = 3  # Signal frequency (Hz)

regular_accel_data = []
regular_gyro_data = []
irregular_accel_data = []
irregular_gyro_data = []

# Extract regular lifting motion data from multiple files
for i in range(1, 7):
    data = pd.read_csv(dir + 'xre{i}.csv')
    regular_accel_data.append(data[['accel_x', 'accel_y', 'accel_z']].values)
    regular_gyro_data.append(data[['gyro_x', 'gyro_y', 'gyro_z']].values)

# Extract irregular lifting motion data from multiple files
for i in range(1, 7):
    data = pd.read_csv(dir + 'xir{i}.csv')
    irregular_accel_data.append(data[['accel_x', 'accel_y', 'accel_z']].values)
    irregular_gyro_data.append(data[['gyro_x', 'gyro_y', 'gyro_z']].values)

# Concatenate the motion data from different experiments
regular_accel_data = np.concatenate(regular_accel_data, axis=0)
regular_gyro_data = np.concatenate(regular_gyro_data, axis=0)
irregular_accel_data = np.concatenate(irregular_accel_data, axis=0)
irregular_gyro_data = np.concatenate(irregular_gyro_data, axis=0)

# Perform FFT on the motion data for each category
# Perform FFT on the accelerometer data for each category
regular_accel_fft = np.fft.fft(regular_accel_data, axis=0).T
irregular_accel_fft = np.fft.fft(irregular_accel_data, axis=0).T

# Frequency axis
freqs = np.fft.fftfreq(len(t), 1 / fs)

# Prepare the data and labels for training
train_data = np.concatenate((np.abs(regular_accel_fft), np.abs(irregular_accel_fft)), axis=0)
regular_labels = np.zeros(len(regular_accel_fft))
irregular_labels = np.ones(len(irregular_accel_fft))
train_labels = np.concatenate((regular_labels, irregular_labels))

# Plot the FFT for visualization (optional)
plt.figure()
plt.plot(freqs, np.abs(regular_accel_fft))
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.title('FFT of Regular Lifting Motion')
plt.grid(True)
plt.show()

plt.figure()
plt.plot(freqs, np.abs(irregular_accel_fft))
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.title('FFT of Irregular Lifting Motion')
plt.grid(True)
plt.show()

# Define the CNN architecture
model = tf.keras.Sequential([
    layers.Reshape((len(train_data[0]), 1), input_shape=(len(train_data[0]),)),
    layers.Conv1D(32, 3, activation='relu'),
    layers.MaxPooling1D(2),
    layers.Conv1D(64, 3, activation='relu'),
    layers.MaxPooling1D(2),
    layers.Flatten(),
    layers.Dense(64, activation='relu'),
    layers.Dense(1, activation='sigmoid')  # Binary classification (regular or irregular)
])

# Compile the model
model.compile(optimizer='adam',
              loss=tf.keras.losses.BinaryCrossentropy(),
              metrics=['accuracy'])

# Train the model
model.fit(train_data, train_labels, epochs=10)

# Save the trained model
model.save('trained_model.h5')


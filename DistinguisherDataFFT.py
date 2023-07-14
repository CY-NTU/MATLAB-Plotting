# -*- coding: utf-8 -*-
"""
Created on Wed Jul 12 19:58:53 2023

@author: 32062
"""

import csv
import numpy as np
import matplotlib.pyplot as plt

# Define the file paths
file_up = 'E:/NTU/Research/Exoskeleton/Distinguisher/test1_up.csv'
file_mid = 'E:/NTU/Research/Exoskeleton/Distinguisher/test1_mid.csv'
file_low = 'E:/NTU/Research/Exoskeleton/Distinguisher/test1_low.csv'

# Load the data from the CSV files
data_up = []
with open(file_up, 'r') as file:
    csv_reader = csv.reader(file)
    next(csv_reader)  # Skip the header row
    for row in csv_reader:
        data_up.append(row[1:])

data_mid = []
with open(file_mid, 'r') as file:
    csv_reader = csv.reader(file)
    next(csv_reader)  # Skip the header row
    for row in csv_reader:
        data_mid.append(row[1:])

data_low = []
with open(file_low, 'r') as file:
    csv_reader = csv.reader(file)
    next(csv_reader)  # Skip the header row
    for row in csv_reader:
        data_low.append(row[1:])

# Convert the data to numpy arrays
data_up = np.array(data_up, dtype=float)
data_mid = np.array(data_mid, dtype=float)
data_low = np.array(data_low, dtype=float)

# Extract the accelerometer data
acc_up = data_up[:, 1:4]
acc_mid = data_mid[:, 1:4]
acc_low = data_low[:, 1:4]

# Set the sample rate and window size for FFT
sample_rate = 416  # Sample rate in Hz
window_size = 512  # Size of the FFT window
frequencies = np.fft.rfftfreq(window_size, 1/sample_rate)

# Perform FFT on the accelerometer data and average the results
fft_up = np.abs(np.fft.rfft(acc_up, n=window_size)).mean(axis=0)
fft_mid = np.abs(np.fft.rfft(acc_mid, n=window_size)).mean(axis=0)
fft_low = np.abs(np.fft.rfft(acc_low, n=window_size)).mean(axis=0)

# Plot the averaged FFT results
plt.figure(figsize=(12, 8))
plt.plot(frequencies, fft_up, label='Upward', color='#F70000')
plt.plot(frequencies, fft_mid, label='Mid', color='#62A9FF')
plt.plot(frequencies, fft_low, label='Lower', color='#00FF00')
plt.xlabel('Frequency (Hz)', fontsize=18)
plt.ylabel('Amplitude', fontsize=18)
plt.title('Averaged FFT - Accelerometer Axes', fontsize=20)
plt.legend(fontsize=16)
plt.grid(True)
plt.show()

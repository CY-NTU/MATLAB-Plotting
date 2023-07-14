# -*- coding: utf-8 -*-
"""
Created on Thu Jul 13 14:55:36 2023

@author: 32062
"""

import csv
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import LSTM, Dense
from keras.callbacks import EarlyStopping
from sklearn.preprocessing import LabelEncoder

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

# Define the labels for each dataset
labels_up = np.array(["regular_up"] * len(data_up))
labels_mid = np.array(["regular_mid"] * len(data_mid))
labels_low = np.array(["regular_low"] * len(data_low))

# Split the data into training and validation sets
X_train_up, X_val_up, y_train_up, y_val_up = train_test_split(acc_up, labels_up, test_size=0.3, random_state=42)
X_train_mid, X_val_mid, y_train_mid, y_val_mid = train_test_split(acc_mid, labels_mid, test_size=0.3, random_state=42)
X_train_low, X_val_low, y_train_low, y_val_low = train_test_split(acc_low, labels_low, test_size=0.3, random_state=42)

# Reshape the training and validation data for LSTM
X_train_up = X_train_up.reshape((X_train_up.shape[0], X_train_up.shape[1], 1))
X_val_up = X_val_up.reshape((X_val_up.shape[0], X_val_up.shape[1], 1))
X_train_mid = X_train_mid.reshape((X_train_mid.shape[0], X_train_mid.shape[1], 1))
X_val_mid = X_val_mid.reshape((X_val_mid.shape[0], X_val_mid.shape[1], 1))
X_train_low = X_train_low.reshape((X_train_low.shape[0], X_train_low.shape[1], 1))
X_val_low = X_val_low.reshape((X_val_low.shape[0], X_val_low.shape[1], 1))

# Define the LSTM model
model_up = Sequential()
model_up.add(LSTM(64, input_shape=(3, 1)))
model_up.add(Dense(3, activation='softmax'))
model_up.compile(loss='sparse_categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

model_mid = Sequential()
model_mid.add(LSTM(64, input_shape=(3, 1)))
model_mid.add(Dense(3, activation='softmax'))
model_mid.compile(loss='sparse_categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

model_low = Sequential()
model_low.add(LSTM(64, input_shape=(3, 1)))
model_low.add(Dense(3, activation='softmax'))
model_low.compile(loss='sparse_categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

# Define early stopping callback
early_stopping = EarlyStopping(monitor='val_loss', patience=5, verbose=1)

# Encode labels using label encoding
label_encoder = LabelEncoder()
y_train_up_encoded = label_encoder.fit_transform(y_train_up)
y_val_up_encoded = label_encoder.transform(y_val_up)
y_train_mid_encoded = label_encoder.fit_transform(y_train_mid)
y_val_mid_encoded = label_encoder.transform(y_val_mid)
y_train_low_encoded = label_encoder.fit_transform(y_train_low)
y_val_low_encoded = label_encoder.transform(y_val_low)

# Train the LSTM model
history_up = model_up.fit(X_train_up, y_train_up_encoded, validation_data=(X_val_up, y_val_up_encoded),
                          epochs=50, batch_size=32, verbose=1, callbacks=[early_stopping])
history_mid = model_mid.fit(X_train_mid, y_train_mid_encoded, validation_data=(X_val_mid, y_val_mid_encoded),
                            epochs=50, batch_size=32, verbose=1, callbacks=[early_stopping])
history_low = model_low.fit(X_train_low, y_train_low_encoded, validation_data=(X_val_low, y_val_low_encoded),
                            epochs=50, batch_size=32, verbose=1, callbacks=[early_stopping])

# Get the predicted labels
y_pred_up = model_up.predict(X_val_up)
y_pred_mid = model_mid.predict(X_val_mid)
y_pred_low = model_low.predict(X_val_low)

# Perform FFT on validation data
fft_val_up = np.fft.fft(X_val_up, axis=0)
frequencies_val_up = np.fft.fftfreq(len(X_val_up))

fft_val_mid = np.fft.fft(X_val_mid, axis=0)
frequencies_val_mid = np.fft.fftfreq(len(X_val_mid))

fft_val_low = np.fft.fft(X_val_low, axis=0)
frequencies_val_low = np.fft.fftfreq(len(X_val_low))

# Perform FFT on predicted data
fft_pred_up = np.fft.fft(y_pred_up, axis = 0)
frequencies_pred_up = np.fft.fftfreq(len(y_pred_up))

fft_pred_mid = np.fft.fft(y_pred_mid, axis = 0)
frequencies_pred_mid = np.fft.fftfreq(len(y_pred_mid))

fft_pred_low = np.fft.fft(y_pred_low, axis = 0)
frequencies_pred_low = np.fft.fftfreq(len(y_pred_low))

# Plot the FFT results - Up sensor
plt.figure(figsize=(12, 6))

plt.subplot(1, 3, 1)
plt.plot(frequencies_val_up, np.abs(fft_val_up[:, 0]), color = 'red', label='Validation Data - X-axis')
plt.plot(frequencies_val_up, np.abs(fft_pred_up[:, 0]), color='red', linestyle='--', label='Predicted Data - X-axis')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Validation Data Up (X-axis)')
plt.legend()

plt.subplot(1, 3, 2)
plt.plot(frequencies_val_up, np.abs(fft_val_up[:, 1]), color = 'green', label='Validation Data - Y-axis')
plt.plot(frequencies_val_up, np.abs(fft_pred_up[:, 1]), color='green', linestyle='--', label='Predicted Data - Y-axis')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Validation Data Up (Y-axis)')
plt.legend()

plt.subplot(1, 3, 3)
plt.plot(frequencies_val_up, np.abs(fft_val_up[:, 2]), color = 'blue', label='Validation Data - Z-axis')
plt.plot(frequencies_val_up, np.abs(fft_pred_up[:, 2]), color='blue', linestyle='--', label='Predicted Data - Z-axis')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Validation Data Up (Z-axis)')
plt.legend()

plt.tight_layout()
plt.show()

# Plot the FFT results
plt.figure(figsize=(8, 9))

plt.subplot(3, 2, 1)
plt.plot(frequencies_val_up, np.abs(fft_val_up[:, 0, 0]), label='Validation Data')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Validation Data Up')
plt.legend()

plt.subplot(3, 2, 2)
plt.plot(frequencies_pred_up, np.abs(fft_pred_up), label='Predicted Data')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Predicted Data Up')
plt.legend()

plt.subplot(3, 2, 3)
plt.plot(frequencies_val_mid, np.abs(fft_val_mid[:, 0, 0]), label='Validation Data')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Validation Data Mid')
plt.legend()

plt.subplot(3, 2, 4)
plt.plot(frequencies_pred_mid, np.abs(fft_pred_mid), label='Predicted Data')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Predicted Data Mid')
plt.legend()

plt.subplot(3, 2, 5)
plt.plot(frequencies_val_low, np.abs(fft_val_low[:, 0, 0]), label='Validation Data')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Validation Data Low')
plt.legend()

plt.subplot(3, 2, 6)
plt.plot(frequencies_pred_low, np.abs(fft_pred_low), label='Predicted Data')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude')
plt.title('FFT - Predicted Data Low')
plt.legend()

plt.tight_layout()
plt.show()

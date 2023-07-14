clear;clc;
close all;

motion = 'walk';
no = '3f';
colength = '3902';
bodypart = 'leftshank';
sampleinterval = 0.065;

filename = strcat(bodypart,motion,no);
accelrange = strcat('B3:D',colength); 
gyrorange = strcat('E3:G',colength);
magrange = strcat('H3:J',colength);
accellabel = strcat('Accel','-',bodypart,'-',motion,'-',no);
gyrolabel = strcat('Gyro','-',bodypart,'-',motion,'-',no);
maglabel = strcat('Mag','-',bodypart,'-',motion,'-',no);
Title = strcat(bodypart,'-',motion,'-',no);

accel = readmatrix(filename,'Range',accelrange);
gyro = readmatrix(filename,'Range',gyrorange);
mag = readmatrix(filename,'Range',magrange);
num = length(accel);
time = 0:sampleinterval:sampleinterval*(num-1);

% Plot the raw dataset
subplot(3,1,1)
plot(time,gyro);
xlabel("Time");
ylabel(gyrolabel);
legend(["X" "Y" "Z"]);
subplot(3,1,2)
plot(time,gyro);
xlabel("Time");
ylabel(gyrolabel);
legend(["X" "Y" "Z"]);
subplot(3,1,3)
plot(time,mag);
xlabel("Time");
ylabel(maglabel);
legend(["X" "Y" "Z"]);
sgtitle(Title);

% Load and preprocess the data
gyro_x = gyro(:,1);  % load dataset 1
gyro_y = gyro(:,2);  % load dataset 2
gyro_z = gyro(:,3);  % load dataset 3


% Split each dataset into training and validation sets
% cv = cvpartition(size(gyro_x,1),'HoldOut',0.3);
% idx = cv.test;
num = numel(gyro_x);
numTimeStepsTrain = floor(0.7*num);
idxXTrain = 1:numTimeStepsTrain-1;
idxXVal = numTimeStepsTrain+1 : num-1;
idxYTrain = 2:numTimeStepsTrain;
idxYVal = numTimeStepsTrain+2:num;

% XTrain1 = gyro_x(~idx,:);
% XVal1 = gyro_x(idx,:);
% YTrain1 = % define response variable for data1 training set
% YVal1 = % define response variable for data1 validation set
XTrain1 = gyro_x(idxXTrain)';  
YTrain1 = gyro_x(idxYTrain)';  
XVal1 = gyro_x(idxXVal)';
YVal1 = gyro_x(idxYVal)';

% cv = cvpartition(size(gyro_y,1),'HoldOut',0.3);
% idx = cv.test;
% 
% XTrain2 = gyro_y(~idx,:);
% XVal2 = gyro_y(idx,:);
% YTrain2 = % define response variable for data2 training set
% YVal2 = % define response variable for data2 validation set
XTrain2 = gyro_y(idxXTrain)';
YTrain2 = gyro_y(idxYTrain)';
XVal2 = gyro_y(idxXVal)';
YVal2 = gyro_y(idxYVal)';

% cv = cvpartition(size(gyro_z,1),'HoldOut',0.3);
% idx = cv.test;
% 
% XTrain3 = gyro_z(~idx,:);
% XVal3 = gyro_z(idx,:);
% YTrain3 = % define response variable for data3 training set
% YVal3 = % define response variable for data3 validation set
XTrain3 = gyro_z(idxXTrain)';
YTrain3 = gyro_z(idxYTrain)';
XVal3 = gyro_z(idxXVal)';
YVal3 = gyro_z(idxYVal)';

% Define the LSTM network architecture for each dataset
numFeatures = 1;
numResponses = 1;
numHiddenUnits = 120;

numFeatures1 = numFeatures;  % number of features in the input data for dataset 1
numResponses1 = numResponses;  % number of response variables for dataset 1
numHiddenUnits1 = numHiddenUnits;  % number of hidden units in the LSTM layer for dataset 1
layers1 = [ ...
    sequenceInputLayer(numFeatures1)
    lstmLayer(numHiddenUnits1)
    fullyConnectedLayer(numResponses1)
    regressionLayer];

numFeatures2 = numFeatures;  % number of features in the input data for dataset 2
numResponses2 = numResponses;  % number of response variables for dataset 2
numHiddenUnits2 = numHiddenUnits;  % number of hidden units in the LSTM layer for dataset 2
layers2 = [ ...
    sequenceInputLayer(numFeatures2)
    lstmLayer(numHiddenUnits2)
    fullyConnectedLayer(numResponses2)
    regressionLayer];

numFeatures3 = numFeatures;  % number of features in the input data for dataset 3
numResponses3 = numResponses;  % number of response variables for dataset 3
numHiddenUnits3 = numHiddenUnits;  % number of hidden units in the LSTM layer for dataset 3
layers3 = [ ...
    sequenceInputLayer(numFeatures3)
    lstmLayer(numHiddenUnits3)
    fullyConnectedLayer(numResponses3)
    regressionLayer];

% Specify the training options
MaxEpochs = 200;
InitialLearnRate = 0.01;
LearnRateDropPeriod = 150;
LearnRateDropFactor = 0.15;
options = trainingOptions('adam', ...
    'MaxEpochs',MaxEpochs, ...
'MiniBatchSize', 32, ...
'InitialLearnRate',InitialLearnRate, ...
'LearnRateDropPeriod',LearnRateDropPeriod, ...
'LearnRateDropFactor',LearnRateDropFactor, ...
'ValidationFrequency', 50, ...
'Shuffle', 'every-epoch', ...
'Verbose', false, ...
'Plots', 'training-progress');

% Train the LSTM network on each dataset
net1 = trainNetwork(XTrain1, YTrain1, layers1, options);
net2 = trainNetwork(XTrain2, YTrain2, layers2, options);
net3 = trainNetwork(XTrain3, YTrain3, layers3, options);

% Use the trained networks to predict the future values of each dataset separately
YPred1 = predict(net1, XVal1);
YPred2 = predict(net2, XVal2);
YPred3 = predict(net3, XVal3);

% Plot the forecast result and the validation data in the same figure for each dataset
figure
subplot(3,1,1)
plot(YVal1)
hold on
plot(YPred1)
legend('Validation Data', 'Forecast')
title('Gyroscope X')

subplot(3,1,2)
plot(YVal2)
hold on
plot(YPred2)
legend('Validation Data', 'Forecast')
title('Gyroscope Y')

subplot(3,1,3)
plot(YVal3)
hold on
plot(YPred3)
legend('Validation Data', 'Forecast')
title('Gyroscope Z')

% Save the forecast result in a .csv file
YPred1 = YPred1'; YPred2 = YPred2'; YPred3 = YPred3'; time = time(idxXVal)';
writematrix(time,'GyroPred.xls','Range','A3:A3000');
writematrix(YPred1,'GyroPred.xls','Range','B3:B3000');
writematrix(YPred2,'GyroPred.xls','Range','C3:C3000');
writematrix(YPred3,'GyroPred.xls','Range','D3:D3000');

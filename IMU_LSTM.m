clear;clc;
close all;

samplerate = 240;
sampleinterval = 1/samplerate;
colength = num2str('20000');

re_pre = [];
ir_pre = [];

% Load the CSV file
for cnt = 1:6
    no = num2str(cnt);
    ref = strcat('xre', no, '.csv');
    irf = strcat('xir', no, '.csv');
    range_time = strcat('A1:A', colength);
    range_angle = strcat('B1:B', colength);
    data_re = readmatrix(ref, 'Range', range_angle);
    data_re = lowpass(data_re,4,240);
    data_ir = readmatrix(irf, 'Range', range_angle);
    data_ir = lowpass(data_ir,4,240);
    data_retime = 1:length(data_re);
    data_retime = data_retime';
    data_retime = data_retime * sampleinterval;
    data_irtime = 1:length(data_ir);
    data_irtime = data_irtime';
    data_irtime = data_irtime * sampleinterval;
    lre = length(data_re);
    lir = length(data_ir);

% Let the origin data minus fit line to eliminate shift
    for i = 1 : lre
        pre = polyfit(data_retime,data_re,1);
        basere = polyval(pre,data_retime);
        data_re(i) = data_re(i) - basere(i);
    end
    
    for j = 1 : lir
        pir = polyfit(data_irtime,data_ir,1);
        baseir = polyval(pir,data_irtime);
        data_ir(j) = data_ir(j) - baseir(j);
    end


% Split each dataset into training and validation sets
num_re = numel(data_re);
num_ir = numel(data_ir);
numTimeStepsTrain_re = floor(0.4*num_re);
numTimeStepsTrain_ir = floor(0.4*num_ir);
idxXTrain_re = 1:numTimeStepsTrain_re - 1;
idxXTrain_ir = 1:numTimeStepsTrain_ir - 1;
idxXVal_re = numTimeStepsTrain_re + 1 : num_re - 1;
idxXVal_ir = numTimeStepsTrain_ir + 1 : num_ir - 1;
idxYTrain_re = 2:numTimeStepsTrain_re;
idxYTrain_ir = 2:numTimeStepsTrain_ir;
idxYVal_re = numTimeStepsTrain_re + 2 : num_re;
idxYVal_ir = numTimeStepsTrain_ir + 2 : num_ir;

XTrain_re = data_re(idxXTrain_re)';  
YTrain_re = data_re(idxYTrain_re)';  
XVal_re = data_re(idxXVal_re)';
YVal_re = data_re(idxYVal_re)';

XTrain_ir = data_ir(idxXTrain_ir)';  
YTrain_ir = data_ir(idxYTrain_ir)';  
XVal_ir = data_ir(idxXVal_ir)';
YVal_ir = data_ir(idxYVal_ir)';

% Define the LSTM network architecture for each dataset
numFeatures = 1;
numResponses = 1;
numHiddenUnits = 120;

numFeatures1 = numFeatures;  % number of features in the input data for dataset 1
numResponses1 = numResponses;  % number of response variables for dataset 1
numHiddenUnits1 = numHiddenUnits;  % number of hidden units in the LSTM layer for dataset 1
layers_re = [ ...
    sequenceInputLayer(numFeatures1)
    lstmLayer(numHiddenUnits1)
    fullyConnectedLayer(numResponses1)
    regressionLayer];

numFeatures2 = numFeatures;  % number of features in the input data for dataset 2
numResponses2 = numResponses;  % number of response variables for dataset 2
numHiddenUnits2 = numHiddenUnits;  % number of hidden units in the LSTM layer for dataset 2
layers_ir = [ ...
    sequenceInputLayer(numFeatures2)
    lstmLayer(numHiddenUnits2)
    fullyConnectedLayer(numResponses2)
    regressionLayer];

% Specify the training options
MaxEpochs = 60;
InitialLearnRate = 0.01;
LearnRateDropPeriod = 40;
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
net_re = trainNetwork(XTrain_re, YTrain_re, layers_re, options);
net_ir = trainNetwork(XTrain_ir, YTrain_ir, layers_ir, options);

% Use the trained networks to predict the future values of each dataset separately
YPred_re = predict(net_re, XVal_re);
YPred_ir = predict(net_ir, XVal_ir);

re_pre = horzcat(re_pre,YPred_re);
ir_pre = horzcat(ir_pre,YPred_ir);

% Plot the forecast result and the validation data in the same figure for each dataset
figure(1)
plot(YVal_re,'-.','LineWidth',1.5,'DisplayName',strcat('Validation Data',no))
hold on
plot(YPred_re,'LineWidth',1.5,'DisplayName',strcat('Forecast Data',no))
set(gcf,'Position',[50,50,1000,750])
title('UpLoBa Angle of Regular Pose')
legend

figure(2)
plot(YVal_ir,'-.','LineWidth',1.5,'DisplayName',strcat('Validation Data',no))
hold on
plot(YPred_ir,'LineWidth',1.5,'DisplayName',strcat('Forecast Data',no))
set(gcf,'Position',[50,50,1000,750])
title('UpLoBa Angle of Irregular Pose')
legend

% Save the forecast result in a .csv file
filename_re = strcat('re_forecast.csv');
writematrix(re_pre, filename_re);
filename_ir = strcat('ir_forecast.csv');
writematrix(ir_pre, filename_ir);
end

saveas(figure(1),'UpLoBa Angle of Regular Pose.png')
saveas(figure(2),'UpLoBa Angle of Irregular Pose.png')

clear; clc;
close all;

date = '230413';   % Insert the date of th experiment
state = 'bir';    % Insert the posture and participant
halfwindow = 100;    % Insert the half window to extract one lifting cycle
colength = num2str('950');
Title = 'UpLoBa Angle During One Irregular Lifting Cycle';

angle_align = [];
peak_align = [];
topalign = [];

figure(1)
hold on

% Load the CSV file
for cnt = 1:15
    no = num2str(cnt);
    file = strcat(date, '_', state, no, '.csv');
    [num_rows, num_cols] = size(file);
    range_UpBaRo = strcat('R8:R',colength);
    range_LoBaRo = strcat('C8:C',colength);
%     range_UpBaRo = 'C8:C10000';
%     range_LoBaRo = 'R8:R10000';
    range_UpM1z = strcat('AR8:AR',colength);
    range_UpM1y = strcat('AQ8:AQ',colength);
    range_UpM3z = strcat('AX8:AX',colength);
    range_UpM3y = strcat('AW8:AW',colength);
    range_LoM1z = strcat('AI8:AI',colength);
    range_LoM1y = strcat('AH8:AH',colength);
    range_LoM3z = strcat('AO8:AO',colength);
    range_LoM3y = strcat('AN8:AN',colength);
    data_UpBa = readmatrix(file, 'Range', range_UpBaRo);
    data_LoBa = readmatrix(file, 'Range', range_LoBaRo);
    data_UpM1z = readmatrix(file, 'Range', range_UpM1z);
    data_UpM1y = readmatrix(file, 'Range', range_UpM1y);
    data_UpM3z = readmatrix(file, 'Range', range_UpM3z);
    data_UpM3y = readmatrix(file, 'Range', range_UpM3y);
    data_LoM1z = readmatrix(file, 'Range', range_LoM1z);
    data_LoM1y = readmatrix(file, 'Range', range_LoM1y);
    data_LoM3z = readmatrix(file, 'Range', range_LoM3z);
    data_LoM3y = readmatrix(file, 'Range', range_LoM3y);
    data_minus = zeros(num_rows);
    k1 = zeros(num_rows);
    k2 = zeros(num_rows);
    data_ang = zeros(num_rows);
    for i = 1:length(data_LoBa)
        data_minus(i) = data_UpBa(i) - data_LoBa(i);
        k1(i) = (data_UpM1z(i) - data_UpM3z(i))/(data_UpM1y(i) - data_UpM3y(i));
        k2(i) = (data_LoM1z(i) - data_LoM3z(i))/(data_LoM1y(i) - data_LoM3y(i));
        data_ang(i) = atan((k1(i) - k2(i))/(1 - k1(i) * k2(i))) * 180/pi;
    end

    % Extract the peak area from the whole vector
    data_ang = data_ang';
    data_ang = lowpass(data_ang,4,240);

    angle_align = horzcat(angle_align,data_ang);

    [~, pindex] = max(-data_ang);
    % [pks, pindex] = findpeaks(data_ang,'MinPeakProminence',1,'Annotate','extents');
    start_index = pindex - halfwindow;
    end_index = pindex + halfwindow;
    peak_cycle = data_ang(start_index : end_index);

    peak_align = horzcat(peak_align,peak_cycle);

    sorted_col = sort(abs(data_ang),'descend');
    n_values = round(0.05 * length(sorted_col));
    top_5 = sorted_col(1:n_values);
    
    topalign = [topalign, top_5];

%     plot(peak_cycle,'LineWidth',1.5);
%     xlim([0 200])

    plot(topalign,'LineWidth',1.5);
    xlim([0 50])

%     % Write the extracted values to new CSV files
%     filename = strcat(state, no, '_angle_peak.csv');
%     writematrix(peak_cycle, filename);
%     anglename = strcat('aligned_',state,'_angle.csv');
%     writematrix(angle_align,anglename);
%     peakname = strcat('aligned_',state,'_angle_peak.csv');
%     writematrix(peak_align,peakname);
end

hold off
%title(Title,'FontName','Arial','FontSize',15,'FontWeight','bold')
ylabel('UpLoBa Angle (°)','FontName','Arial','FontSize',15,'FontWeight','bold')
xlabel('No. of Samples','FontName','Arial','FontSize',15,'FontWeight','bold')
box on
saveas(figure(1),Title,'png')
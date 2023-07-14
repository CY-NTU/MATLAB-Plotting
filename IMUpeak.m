clear; clc;
close all;

samplerate = 240;
sampleinterval = 1/samplerate;
colength = num2str('1000');
halfwindow = 50;

figure()
hold on

% Load the CSV file
for cnt = 1:15
    no = num2str(cnt);
    ref = strcat('re', no, '.csv');
    irf = strcat('ir', no, '.csv');
    range_time = strcat('A1:A', colength);
    range_angle = strcat('B1:B', colength);
    data_re = readmatrix(ref, 'Range', range_angle);
    data_re = lowpass(data_re,4,240);
    data_ir = readmatrix(irf, 'Range', range_angle);
    data_ir = lowpass(data_ir,4,240);
    
    % Extract the peak area from the whole vector
    [~, pindex_re] = max(data_re);
    sindex_re = pindex_re - halfwindow;
    eindex_re = pindex_re + halfwindow;
    pcycle_re = data_re(sindex_re : eindex_re);

    [~, pindex_ir] = max(data_ir);
    sindex_ir = pindex_ir - halfwindow;
    eindex_ir = pindex_ir + halfwindow;
    pcycle_ir = data_re(sindex_ir : eindex_ir);

    plot(pcycle_re,'r','LineWidth',1.5,'DisplayName',strcat('re',no));
    plot(pcycle_ir,'b','LineWidth',1.5,'DisplayName',strcat('ir',no));

    % Write the extracted values to a new CSV file
    filename = strcat('re', no, '_angle_peak.csv');
    writematrix(pcycle_re, filename);

    filename = strcat('ir', no, '_angle_peak.csv');
    writematrix(pcycle_ir, filename);

end

hold off
title('Peak UpLo-Back Angle of Different Pose')
legend
ax_f = gcf;
exportgraphics(ax_f, 'Peak UpLo-Back Angle of Different Pose.jpg')
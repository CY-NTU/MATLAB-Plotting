clear; clc;
close all;

samplerate = 240;
sampleinterval = 1/samplerate;
colength = num2str('15000');

figure()
hold on

% Load the CSV file
for cnt = 16:16
    no = num2str(cnt);
    ref = strcat('re', no, '.csv');
    irf = strcat('ir', no, '.csv');
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
    

    plot(data_retime, data_re,'r','LineWidth',1.5,'DisplayName',strcat('re',no))
    plot(data_irtime, data_ir,'b','LineWidth',1.5,'DisplayName',strcat('ir',no))

end

hold off
title('UpLo-Back Angle of Different Pose')
legend
ax_f = gcf;
exportgraphics(ax_f, 'UpLo-Back Angle of Different Pose.jpg')
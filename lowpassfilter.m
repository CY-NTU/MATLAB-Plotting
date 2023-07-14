clear;clc;
close all;

motion = 'squattoe';
no = '2f';
colength = '239';
% accelrange = strcat('B3:D',colength);
% gyrorange = strcat('E3:G',colength);
% magrange = strcat('H3:J',colength);
range = strcat('B3:D',colength);
sampleinterval = 0.064;
fpass = 3;
fs = 1/sampleinterval;

for idx = 1:8
    if idx == 1
        filename = strcat('leftfoot',motion,no);
    elseif idx == 2
        filename = strcat('leftshank',motion,no);
    elseif idx == 3
        filename = strcat('leftthigh',motion,no);
    elseif idx == 4
        filename = strcat('rightfoot',motion,no);
    elseif idx == 5
        filename = strcat('rightshank',motion,no);
    elseif idx == 6
        filename = strcat('rightthigh',motion,no);
    elseif idx == 7
        filename = strcat('waist',motion,no);
    elseif idx == 8
        filename = strcat('torso',motion,no);
    end
        
% filenamef = strcat(filename,'f');
facc = strcat(filename,'_accpd.xls');
fgyro = strcat(filename,'_gyropd.xls');
fmag = strcat(filename,'_magpd.xls');
range = strcat('B3:D',colength);
accel = readmatrix(facc,'Range',range);
gyro = readmatrix(fgyro,'Range',range);
mag = readmatrix(fmag,'Range',range);
num = length(accel);
time = 1:num; time = time'; time = time*sampleinterval;
strtime = num2str(time);

x_acc = accel(:, 1);
x_lowpass_acc = lowpass(x_acc,fpass,fs);
y_acc = accel(:, 2);
y_lowpass_acc = lowpass(y_acc,fpass,fs);
z_acc = accel(:, 3);
z_lowpass_acc = lowpass(z_acc,fpass,fs);
x_ang = gyro(:, 1);
x_lowpass_ang = lowpass(x_ang,fpass,fs);
y_ang = gyro(:, 2);
y_lowpass_ang = lowpass(y_ang,fpass,fs);
z_ang = gyro(:, 3);
z_lowpass_ang = lowpass(z_ang,fpass,fs);
x_mag = mag(:, 1);
x_lowpass_mag = lowpass(x_mag,fpass,fs);
y_mag = mag(:, 2);
y_lowpass_mag = lowpass(y_mag,fpass,fs);
z_mag = mag(:, 3);
z_lowpass_mag = lowpass(z_mag,fpass,fs);

file = strcat(filename,'_pd','.csv');
header = {'Time', ' ', 'Accel',' ',' ','Gyro',' ',' ','Mag',' '};
subheader = {'mm:ss.000','X','Y','Z','X','Y','Z','X','Y','Z'};
file = fopen(file,'w');
for j = 1:length(header)
if j == length(header)
    fprintf(file,'%s\n',header{1,j});
else
    fprintf(file,'%s',header{1,j});
    fprintf(file,',');
end
end

for i = 1:length(subheader)
if i == length(subheader)
    fprintf(file,'%s\n',subheader{1,i});
else
    fprintf(file,'%s',subheader{1,i});
    fprintf(file,',');
end
end

for k = 1:length(strtime)
    fprintf(file,'%s',strtime(k,:));
    fprintf(file,',');
    fprintf(file,'%s',x_lowpass_acc(k,:));
    fprintf(file,',');
    fprintf(file,'%s',y_lowpass_acc(k,:));
    fprintf(file,',');
    fprintf(file,'%s',z_lowpass_acc(k,:));
    fprintf(file,',');
    fprintf(file,'%s',x_lowpass_ang(k,:));
    fprintf(file,',');
    fprintf(file,'%s',y_lowpass_ang(k,:));
    fprintf(file,',');
    fprintf(file,'%s',z_lowpass_ang(k,:));
    fprintf(file,',');
    fprintf(file,'%s',x_lowpass_mag(k,:));
    fprintf(file,',');
    fprintf(file,'%s',y_lowpass_mag(k,:));
    fprintf(file,',');
    fprintf(file,'%s\n',z_lowpass_mag(k,:));
end
fclose(file);
end

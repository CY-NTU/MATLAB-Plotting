clc;clear;

addpath('quaternion_library');  
addpath('static_estimate');

motion = 'squattoe';
no = '2f';
sampleinterval = 0.064;
colength = '237';
accelrange = strcat('B3:D',colength); 
gyrorange = strcat('E3:G',colength);
magrange = strcat('H3:J',colength);

for idx = 1:8
    if idx == 1
        filename = strcat('leftfoot',motion,no,'_pd');
    elseif idx == 2
        filename = strcat('leftshank',motion,no,'_pd');
    elseif idx == 3
        filename = strcat('leftthigh',motion,no,'_pd');
    elseif idx == 4
        filename = strcat('rightfoot',motion,no,'_pd');
    elseif idx == 5
        filename = strcat('rightshank',motion,no,'_pd');
    elseif idx == 6
        filename = strcat('rightthigh',motion,no,'_pd');
    elseif idx == 7
        filename = strcat('waist',motion,no,'_pd');
    elseif idx == 8
        filename = strcat('torso',motion,no,'_pd');
    end

    accel = readmatrix(filename,'Range',accelrange);
    gyro = readmatrix(filename,'Range',gyrorange);
    mag = readmatrix(filename,'Range',magrange);
    num = length(accel);
    time = 0:sampleinterval:sampleinterval*(num-1);

    Rotation_estimate = estimate_orientation(accel(1,:), mag(1,:));
    quat_estimate = rotMat2quatern(Rotation_estimate);
    quat_estimate =  quaternConj(quat_estimate);
    
    AHRS = MadgwickAHRS('SamplePeriod', sampleinterval, 'Beta', 0.1, 'Quaternion', quat_estimate);    
    %AHRS = MadgwickAHRS('SamplePeriod', 1/40, 'Beta', 0.1, 'Quaternion', quat_estimate); %subject 11 and 7

    
    quaternion = zeros(length(time), 4);
    for t = 1:length(time)
        %AHRS.Update(gyroscope(t,:) * (pi/180), accel(t,:), magnetometer(t,:));	%gyroscope units must be radians
        AHRS.Update(gyro(t,:), accel(t,:), mag(t,:));	%gyroscope units must be radians
        quaternion(t, :) =  quaternConj(AHRS.Quaternion);
        quaternion(t,:)
    end
  
if idx == 1
    quaternion_toe_l= quaternion;  %左脚
    save quaternion_toe_l.mat quaternion_toe_l
elseif idx == 2
    quaternion_tibia_l= quaternion;  %左小腿
    save quaternion_tibia_l.mat quaternion_tibia_l
elseif idx == 3
    quaternion_femur_l= quaternion;  %左大腿
    save quaternion_femur_l.mat quaternion_femur_l
elseif idx == 4
    quaternion_toe_r= quaternion;  %右脚
    save quaternion_toe_r.mat quaternion_toe_r
elseif idx == 5
    quaternion_tibia_r= quaternion;  %右小腿
    save quaternion_tibia_r.mat quaternion_tibia_r
elseif idx == 6
    quaternion_femur_r= quaternion;  %右大腿
    save quaternion_femur_r.mat quaternion_femur_r
elseif idx == 7
    quaternion_pelvis= quaternion;  %骨盆（腰部base）
    save quaternion_pelvis.mat quaternion_pelvis
elseif idx == 8
    quaternion_torso= quaternion;  %躯干
    save quaternion_torso.mat quaternion_torso

end
end
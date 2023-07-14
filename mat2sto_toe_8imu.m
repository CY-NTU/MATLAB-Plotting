close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

sampleinterval = 0.064;

load('quaternion_femur_l.mat');
load('quaternion_femur_r.mat');
load('quaternion_tibia_l.mat');
load('quaternion_tibia_r.mat');
load('quaternion_toe_l.mat');
load('quaternion_toe_r.mat');
load('quaternion_pelvis.mat');
load('quaternion_torso.mat');

    quaternion_toe_l(:,1)=-quaternion_toe_l(:,1);
    quaternion_toe_l=-quaternion_toe_l;

    quaternion_toe_r(:,1)=-quaternion_toe_r(:,1);
    quaternion_toe_r=-quaternion_toe_r;
    
    quaternion_pelvis(:,1)=-quaternion_pelvis(:,1);

    quaternion_torso(:,1)=-quaternion_torso(:,1);

    quaternion_tibia_l(:,1)=-quaternion_tibia_l(:,1);
    quaternion_tibia_l=-quaternion_tibia_l;

    quaternion_femur_l(:,1)=-quaternion_femur_l(:,1);
    quaternion_femur_l=-quaternion_femur_l;

    quaternion_tibia_r(:,1)=-quaternion_tibia_r(:,1);
    quaternion_tibia_r=-quaternion_tibia_r;

    quaternion_femur_r(:,1)=-quaternion_femur_r(:,1);
    quaternion_femur_r=-quaternion_femur_r;

num = length(quaternion_toe_l(:,1));
pelvis = quaternion_pelvis(1:num,:);
torso = quaternion_torso(1:num,:);
tibia_r = quaternion_tibia_r(1:num,:);
femur_r = quaternion_femur_r(1:num,:);
tibia_l = quaternion_tibia_l(1:num,:);
femur_l = quaternion_femur_l(1:num,:);
toe_l = quaternion_toe_l(1:num,:);
toe_r = quaternion_toe_r(1:num,:);
time = 0:num-1;
time = time';
time = time * sampleinterval;


% pelvis_imu	tibia_r_imu	femur_r_imu	tibia_l_imu	femur_l_imu	toe_l_imu	toe_r_imu	torso_imu
strtime = num2str(time);
pelvis_imu = strcat(num2str(pelvis(:,1)),',',num2str(pelvis(:,2)),',',...
       num2str(pelvis(:,3)),',',num2str(pelvis(:,4)));
tibia_r_imu = strcat(num2str(tibia_r(:,1)),',',num2str(tibia_r(:,2)),',',...
       num2str(tibia_r(:,3)),',',num2str(tibia_r(:,4)));
femur_r_imu = strcat(num2str(femur_r(:,1)),',',num2str(femur_r(:,2)),',',...
       num2str(femur_r(:,3)),',',num2str(femur_r(:,4)));
tibia_l_imu = strcat(num2str(tibia_l(:,1)),',',num2str(tibia_l(:,2)),',',...
       num2str(tibia_l(:,3)),',',num2str(tibia_l(:,4)));
femur_l_imu = strcat(num2str(femur_l(:,1)),',',num2str(femur_l(:,2)),',',...
       num2str(femur_l(:,3)),',',num2str(femur_l(:,4)));
toe_l_imu = strcat(num2str(toe_l(:,1)),',',num2str(toe_l(:,2)),',',...
        num2str(toe_l(:,3)),',',num2str(toe_l(:,4)));
toe_r_imu = strcat(num2str(toe_r(:,1)),',',num2str(toe_r(:,2)),',',...
        num2str(toe_r(:,3)),',',num2str(toe_r(:,4)));
torso_imu = strcat(num2str(torso(:,1)),',',num2str(torso(:,2)),',',...
        num2str(torso(:,3)),',',num2str(torso(:,4)));

%将数据导出为以制表符分隔的.txt文件
fid = strcat('SSub1_01','.sto');
%datanames = {'time','pelvis_imu','tibia_r_imu','femur_r_imu','tibia_l_imu','femur_l_imu','toe_l_imu','toe_r_imu'};
datanames = {'time','pelvis_imu','torso_imu','tibia_r_imu','femur_r_imu','tibia_l_imu','femur_l_imu','toe_l_imu','toe_r_imu'};
fid = fopen(fid,'w');
fprintf(fid,'DataRate=15.625000\n');
fprintf(fid,'DataType=Quaternion\n');
fprintf(fid,'version=3\n');
fprintf(fid,'OpenSimVersion=4.1\n');
fprintf(fid,'endheader\n');

for j = 1:length(datanames)
if j == length(datanames)
    fprintf(fid,'%s\n',datanames{1,j});
else
    fprintf(fid,'%s\t',datanames{1,j});
end
end

for k = 1:length(strtime)
    fprintf(fid,'%s\t',strtime(k,:) );
    fprintf(fid,'%s\t',pelvis_imu(k,:));
    fprintf(fid,'%s\t',torso_imu(k,:));
    fprintf(fid,'%s\t',tibia_r_imu(k,:));
    fprintf(fid,'%s\t',femur_r_imu(k,:));
    fprintf(fid,'%s\t',tibia_l_imu(k,:));
    fprintf(fid,'%s\t',femur_l_imu(k,:));
    fprintf(fid,'%s\t',toe_l_imu(k,:));
    fprintf(fid,'%s\n',toe_r_imu(k,:));
end
fclose(fid);
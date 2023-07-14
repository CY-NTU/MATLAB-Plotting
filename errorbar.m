clear; clc;
close all;

% Load data from CSV file
data_re = readmatrix('re_top5_ul.csv');
data_ir = readmatrix('ir_top5_ul.csv');
Title = 'Confidence Interval of Up-Low Angle';

% Calculate mean value of each row
mean_values_re = mean(data_re, 2);
std_values_re = std(data_re,1,2);
lo_limit_re = mean_values_re - std_values_re;
up_limit_re = mean_values_re + std_values_re;

mean_values_ir = mean(data_ir, 2);
std_values_ir = std(data_ir,1,2);
lo_limit_ir = mean_values_ir - std_values_ir;
up_limit_ir = mean_values_ir + std_values_ir;

% Display mean values
disp(mean_values_re);
disp(std_values_re);
disp(lo_limit_re);
disp(up_limit_re);

disp(mean_values_ir);
disp(std_values_ir);
disp(lo_limit_ir);
disp(up_limit_ir);

figure(1)
x_re = 1 : length(mean_values_re);
x_ir = 1 : length(mean_values_ir);
% x_vector = [x',fliplr(x')];
% y_vector = [up_limit,fliplr(lo_limit)];
% patch(x_vector,y_vector, [243 169 114]./255);
% set(patch, 'edgecolor', 'b');
% set(patch, 'FaceAlpha', 0.5);
plot(x_re, mean_values_re, 'color', 'r', 'LineWidth', 1.5);
hold on
plot(x_ir, mean_values_ir, 'color', 'b', 'LineWidth', 1.5);
hold on
shade(x_re,lo_limit_re,x_re,up_limit_re,'FillType',[1 2;2 1],'FillColor',[243 169 114]./255,'FillAlpha',0.3);
hold on
shade(x_ir,lo_limit_ir,x_ir,up_limit_ir,'FillType',[1 2;2 1],'FillColor',[115 194 251]./255,'FillAlpha',0.3);
set(gcf,'Position',[50,50,1000,750])
set(gca,'box','off')
xlabel('Numble of Data Points')
ylabel('Angle (°)')
legend('Regular Pose','Irregular Pose','Location','northeastoutside','Box','off')
title(Title)


% figure(2)
% bar(mean_values)
% hold on
% errhigh = std_values;
% errlow = -std_values;
% er = errorbar(mean_values,errlow,errhigh);    
% er.Color = [0 0 0];                            
% er.LineStyle = 'none'; 

saveas(figure(1),Title,'png')
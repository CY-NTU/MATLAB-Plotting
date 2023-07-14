clear; clc;
close all;

date = '230413';    % Insert the date of th experiment
colength = num2str('950');    % Insert the number of the rows
halfwindow = 100;    % Insert the half window to extract one lifting cycle
samplerate = 240;    % Insert the sample rate if the MoCap system
sampleinterval = 1/samplerate;

colororder_mix = ["#F70000";"#62A9FF";"#B9264F";"#6A6AFF";"#FF7575";"#8C8CFF";"#FF5353";"#9191FF";"#DD597D";"#A095EE";
"#FFA4A4";"#5B5BFF";"#D73E68";"#0000CE";"#FFB5B5";"#AAAAFF";"#FFBBBB";"#3923D6";"#FF62B0";"#6755E3"];

ang_align_re = [];
ang_align_ir = [];
topalign_re = [];
topalign_ir = [];
peakalign_re = [];
peakalign_ir = [];

% Load the CSV file
for cnt = 1:15
    no = num2str(cnt);
    file_re = strcat(date, '_bre', no, '.csv');
    file_ir = strcat(date, '_bir', no, '.csv');

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

    data_retime = 1:str2double(colength);
    data_retime = data_retime';
    data_retime = data_retime * sampleinterval;
    data_irtime = 1:str2double(colength);
    data_irtime = data_irtime';
    data_irtime = data_irtime * sampleinterval;

    data_UpBa_re = readmatrix(file_re, 'Range', range_UpBaRo);
    data_LoBa_re = readmatrix(file_re, 'Range', range_LoBaRo);
    data_UpM1z_re = readmatrix(file_re, 'Range', range_UpM1z);
    data_UpM1y_re = readmatrix(file_re, 'Range', range_UpM1y);
    data_UpM3z_re = readmatrix(file_re, 'Range', range_UpM3z);
    data_UpM3y_re = readmatrix(file_re, 'Range', range_UpM3y);
    data_LoM1z_re = readmatrix(file_re, 'Range', range_LoM1z);
    data_LoM1y_re = readmatrix(file_re, 'Range', range_LoM1y);
    data_LoM3z_re = readmatrix(file_re, 'Range', range_LoM3z);
    data_LoM3y_re = readmatrix(file_re, 'Range', range_LoM3y);
    data_minus_re = [];
    k1_re = [];
    k2_re = [];
    data_ang_re = [];
    for i = 1:length(data_LoBa_re)
        data_minus_re(i) = data_UpBa_re(i) - data_LoBa_re(i);
        k1_re(i) = (data_UpM1z_re(i) - data_UpM3z_re(i))/(data_UpM1y_re(i) - data_UpM3y_re(i));
        k2_re(i) = (data_LoM1z_re(i) - data_LoM3z_re(i))/(data_LoM1y_re(i) - data_LoM3y_re(i));
        data_ang_re(i) = atan((k1_re(i) - k2_re(i))/(1 - k1_re(i) * k2_re(i))) * 180/pi;
    end

    data_ang_re = data_ang_re';
    lre = length(data_ang_re);

    if lre < str2double(colength)
        data_ang_re(lre+1 : str2double(colength)) = 0;
    end

    data_UpBa_ir = readmatrix(file_ir, 'Range', range_UpBaRo);
    data_LoBa_ir = readmatrix(file_ir, 'Range', range_LoBaRo);
    data_UpM1z_ir = readmatrix(file_ir, 'Range', range_UpM1z);
    data_UpM1y_ir = readmatrix(file_ir, 'Range', range_UpM1y);
    data_UpM3z_ir = readmatrix(file_ir, 'Range', range_UpM3z);
    data_UpM3y_ir = readmatrix(file_ir, 'Range', range_UpM3y);
    data_LoM1z_ir = readmatrix(file_ir, 'Range', range_LoM1z);
    data_LoM1y_ir = readmatrix(file_ir, 'Range', range_LoM1y);
    data_LoM3z_ir = readmatrix(file_ir, 'Range', range_LoM3z);
    data_LoM3y_ir = readmatrix(file_ir, 'Range', range_LoM3y);
    data_minus_ir = [];
    k1_ir = [];
    k2_ir = [];
    data_ang_ir = [];
    for j = 1:length(data_LoBa_ir)
        data_minus_ir(j) = data_UpBa_ir(j) - data_LoBa_ir(j);
        k1_ir(j) = (data_UpM1z_ir(j) - data_UpM3z_ir(j))/(data_UpM1y_ir(j) - data_UpM3y_ir(j));
        k2_ir(j) = (data_LoM1z_ir(j) - data_LoM3z_ir(j))/(data_LoM1y_ir(j) - data_LoM3y_ir(j));
        data_ang_ir(j) = atan((k1_ir(j) - k2_ir(j))/(1 - k1_ir(j) * k2_ir(j))) * 180/pi;
    end

    data_ang_ir = data_ang_ir';
    lir = length(data_ang_ir);

    if lir < str2double(colength)
        data_ang_ir(lir+1 : str2double(colength)) = 0;
    end

    ang_align_re = [ang_align_re, data_ang_re];
    ang_align_ir = [ang_align_ir, data_ang_ir];

    % Extract the top 5% largest values from the column
    sorted_col_re = sort(abs(data_ang_re),'descend');
    n_values_re = round(0.05 * length(sorted_col_re));
    top_5_re = sorted_col_re(1:n_values_re);

    sorted_col_ir = sort(abs(data_ang_ir),'descend');
    n_values_ir = round(0.05 * length(sorted_col_ir));
    top_5_ir = sorted_col_ir(1:n_values_ir);

    topalign_re = [topalign_re, top_5_re];
    topalign_ir = [topalign_ir, top_5_ir];

    % Extract the peak area from the whole vector
    [~, pindex_re] = max(abs(data_ang_re));
    start_index_re = pindex_re - halfwindow;
    end_index_re = pindex_re + halfwindow;
    peak_cycle_re = data_ang_re(start_index_re : end_index_re);

    [~, pindex_ir] = max(abs(data_ang_ir));
    start_index_ir = pindex_ir - halfwindow;
    end_index_ir = pindex_ir + halfwindow;
    peak_cycle_ir = data_ang_ir(start_index_ir : end_index_ir);

    compare_re = [end_index_re,length(data_ang_re)];
    end_index_re = min(compare_re);
    compare_ir = [end_index_ir,length(data_ang_ir)];
    end_index_ir = min(compare_ir);

    peakalign_re = [peakalign_re, peak_cycle_re];
    peakalign_ir = [peakalign_ir, peak_cycle_ir];

    figure(1)
    plot(data_retime, data_ang_re, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime, data_ang_ir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    xlabel('Time (s)')
    ylabel('Angle (°)')
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Angle between Rigidbodies for Different Pose'))
    legend('Location','northeastoutside','Box','off')

    figure(2)
    plot(top_5_re, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(top_5_ir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    xlabel('Numble of Data Points')
    ylabel('Angle (°)')
    set(gcf,'Position',[50,50,1000,750])
    title('Top 5% of Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')
    
    figure(3)
    plot(peak_cycle_re, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(peak_cycle_ir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    xlabel('Numble of Data Points')
    ylabel('Angle (°)')
    set(gcf,'Position',[50,50,1000,750])
    title('Peak Cycle of Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

end

% Write the calculated angle to a new CSV file
filename_re = 're_CalAng.csv';
writematrix(ang_align_re, filename_re);

filename_ir = 'ir_CalAng.csv';
writematrix(ang_align_ir, filename_ir);

% Write the extracted top values to a new CSV file
topname_re =  're_top.csv';
writematrix(topalign_re, topname_re);

topname_ir =  'ir_top.csv';
writematrix(topalign_ir, topname_ir);

% Write the extracted peak values to a new CSV file
peakname_re =  're_peak.csv';
writematrix(peakalign_re, peakname_re);

peakname_ir =  'ir_peak.csv';
writematrix(peakalign_ir, peakname_ir);

% Save the plots
saveas(figure(1),'Angle.png')
saveas(figure(2),'Top 5% of 5Angle for Different Pose.png')
saveas(figure(3),'Peak Cycle of Angle for Different Pose.png')
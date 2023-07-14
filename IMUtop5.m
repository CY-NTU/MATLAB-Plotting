clear; clc;
close all;

samplerate = 240;
sampleinterval = 1/samplerate;
colength = num2str('1000');
halfwindow = 50;

re_topalign = [];
ir_topalign = [];
re_peakalign = [];
ir_peakalign = [];

% Load the CSV file
for cnt = 1:10
    no = num2str(cnt);
    ref = strcat('zre', no, '.csv');
    irf = strcat('zir', no, '.csv');
    range_angle = strcat('B1:B', colength);
    data_re = readmatrix(ref, 'Range', range_angle);
    data_re = lowpass(data_re,2,240);
    data_ir = readmatrix(irf, 'Range', range_angle);
    data_ir = lowpass(data_ir,2,240);
    data_retime = 1:length(data_re);
    data_retime = data_retime';
    data_retime = data_retime * sampleinterval;
    data_irtime = 1:length(data_ir);
    data_irtime = data_irtime';
    data_irtime = data_irtime * sampleinterval;

    % Smooth the curve
    data_re = smooth(data_retime,data_re,0.1,'rloess');
    data_ir = smooth(data_irtime,data_ir,0.1,'rloess');

    % Extract the peak cycle from the dataset 
    [~, pindex_re] = max(abs(data_re));
%     [pks, pindex] = findpeaks(data_ang,'MinPeakProminence',1,'Annotate','extents');
    start_index_re = pindex_re - halfwindow;
    end_index_re = pindex_re + halfwindow;
    if end_index_re < length(data_re)
        peak_re = data_re(start_index_re : end_index_re);
    elseif end_index_re > length(data_re)
        peak_re = data_re(start_index_re : length(data_re));
    end

    [~, pindex_ir] = max(abs(data_ir));
%     [pks, pindex] = findpeaks(data_ang,'MinPeakProminence',1,'Annotate','extents');
    start_index_ir = pindex_ir - halfwindow;
    end_index_ir = pindex_ir + halfwindow;
    if end_index_ir < length(data_ir)
        peak_ir = data_ir(start_index_ir : end_index_ir);
    elseif end_index_ir > length(data_ir)
        peak_ir = data_ir(start_index_ir : length(data_ir));
    end

    re_peakalign = [re_peakalign;peak_re];
    ir_peakalign = [ir_peakalign;peak_ir];
%     re_peakalign(:,cnt) = peak_re;
%     ir_peakalign(:,cnt) = peak_ir;
    
    % Extract the top 5% largest values from the dataset
    sorted_col_re = sort(abs(data_re),'descend');
    n_values_re = round(0.05 * length(sorted_col_re));
    top_5percent_re = sorted_col_re(1:n_values_re);

    sorted_col_ir = sort(abs(data_ir),'descend');
    n_values_ir = round(0.05 * length(sorted_col_ir));
    top_5percent_ir = sorted_col_ir(1:n_values_ir);

    re_topalign = [re_topalign;top_5percent_re];
    ir_topalign = [ir_topalign;top_5percent_ir];
%     re_topalign(:,cnt) = top_5percent_re;
%     ir_topalign(:,cnt) = top_5percent_ir;

    % Draw the curve of top 5% data for each pose
    figure(1)
    plot(top_5percent_re,'r','LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(top_5percent_ir,'b','LineWidth',1.5,'DisplayName',strcat('ir',no))
    set(gcf,'Position',[50,50,1000,750])
    title('Top 5% of UpLo-Back Angle for Different Pose')
    legend

    figure(2)
    plot(peak_re,'r','LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(peak_ir,'b','LineWidth',1.5,'DisplayName',strcat('ir',no))
    set(gcf,'Position',[50,50,1000,750])
    title('Peak Cycle of UpLo-Back Angle for Different Pose')
    legend

    figure(3)
    plot(data_retime, data_re,'r','LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime, data_ir,'b','LineWidth',1.5,'DisplayName',strcat('ir',no))
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('UpLo-Back Angle'))
    legend

    % Write the extracted values to a new CSV file
    filename_re = 're_top5.csv';
    writematrix(re_topalign, filename_re);
    filename_ir = 'ir_top5.csv';
    writematrix(ir_topalign, filename_ir);
    fname_re = 're_peak.csv';
    writematrix(re_peakalign, fname_re);
    fname_ir = 'ir_peak.csv';
    writematrix(ir_peakalign, fname_ir);
end

saveas(figure(1),'Top 5% of UpLo-Back Angle for Different Pose.png')
saveas(figure(2),'Peak Cycle of UpLo-Back Angle for Different Pose.png')
saveas(figure(3),'UpLo-Back Angle.png')
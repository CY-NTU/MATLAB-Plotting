clear; clc;
close all;

samplerate = 300;
sampleinterval = 1/samplerate;
colength = num2str('20000');
halfwindow = 150;

% colororder_re = ["#F70000";"#FFF06A";"#FFD062";"#CB876D";"#D1A0A0";"#FF7575";"#D73168";"#FFFF84";"#B9264F";"#CF8D72";"#C48484";"#B96F6F";"#DFB4A4";"#FF7DFF";"#CB59E8"];
% colororder_ir = ["#5B5BFF";"#8282FF";"#29AFD6";"#8ED6EA";"#5EAE9E";"#C0E0DA";"#9999FF";"#5757FF";"#62A9FF";"#BBDAFF";"#3DE4FC";"#33FDC0";"#01F33E";"#1FCB4A";"#48FB0D"];
% colororder_mix =["#F70000";"#5B5BFF";"#FFF06A";"#8282FF";"#FFD062";"#29AFD6";"#FFD062";"#29AFD6";"#CB876D";"#8ED6EA";"#D1A0A0";"#5EAE9E";"#FF7575";"#C0E0DA";
% "#D73168";"#9999FF";"#FFFF84";"#5757FF";"#B9264F";"#62A9FF";"#CF8D72";"#BBDAFF";"#C48484";"#3DE4FC";"#B96F6F";"#33FDC0";"#DFB4A4";"#01F33E";"#FF7DFF";"#1FCB4A";"#CB59E8";"#48FB0D"];
 colororder_mix = ["#F70000";"#62A9FF";"#B9264F";"#6A6AFF";"#FF7575";"#8C8CFF"];

% d = designfilt("lowpassiir", PassbandFrequency=0.2,StopbandFrequency=0.3,DesignMethod="butter");

% Load the CSV file
for cnt = 1:3
    no = num2str(cnt);
    ref = strcat('wre4_', no, '.csv');
    irf = strcat('wir4_', no, '.csv');
    range_time = strcat('A1:A', colength);
    range_angle = strcat('B1:B', colength);
    data_re = readmatrix(ref, 'Range', range_angle);
    data_re = lowpass(data_re,1,240);
%     data_re = filtfilt(d,data_re);
    data_ir = readmatrix(irf, 'Range', range_angle);
    data_ir = lowpass(data_ir,1,240);
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
        pre = polyfit(data_retime,data_re,5);
        basere = polyval(pre,data_retime);
        data_re(i) = data_re(i) - basere(i);
    end
    
    for j = 1 : lir
        pir = polyfit(data_irtime,data_ir,5);
        baseir = polyval(pir,data_irtime);
        data_ir(j) = data_ir(j) - baseir(j);
    end

    % Smooth the curve
    data_re = smooth(data_retime,data_re,0.1,'rloess');
    data_ir = smooth(data_irtime,data_ir,0.1,'rloess');

    % Extract the first 30% largest values from the column
    first_re = data_re(1:round(0.3*lre));
    first_retime = data_retime(1:round(0.3*lre));
    sorted_col_re = sort(abs(first_re),'descend');
    n_values_re = round(0.05 * length(sorted_col_re));
    top_5percent_re = sorted_col_re(1:n_values_re);

    first_ir = data_ir(1:round(0.3*lir));
    first_irtime = data_irtime(1:round(0.3*lir));
    sorted_col_ir = sort(abs(first_ir),'descend');
    n_values_ir = round(0.05 * length(sorted_col_ir));
    top_5percent_ir = sorted_col_ir(1:n_values_ir);

    % Extract the peak cycle from the dataset
    [pks_re, pindex_re] = findpeaks(data_re,'MinPeakDistance',200,'Annotate','extents');
    start_index_re = pindex_re - halfwindow;
    end_index_re = pindex_re + halfwindow;
    peak_re = data_re(start_index_re : end_index_re);

    [pks_ir, pindex_ir] = findpeaks(data_ir,'MinPeakDistance',200,'Annotate','extents');
    start_index_ir = pindex_ir - halfwindow;
    end_index_ir = pindex_ir + halfwindow;
    peak_ir = data_ir(start_index_ir : end_index_ir);

    % Write the extracted values to a new CSV file
    filename_re = strcat('re', no, '_top5.csv');
    writematrix(top_5percent_re, filename_re);
    filename_ir = strcat('ir', no, '_top5.csv');
    writematrix(top_5percent_ir, filename_ir);
    
    % Draw the curve of angle for each pose
    figure(1)
    plot(data_retime, data_re,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime, data_ir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('UpLo-Back Angle - Continuous'))
    legend

    % Draw the curve of top 5% data for each pose
    figure(2)
    plot(top_5percent_re,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(top_5percent_ir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Top 5% of UpLoBa Angle - Continuous'))
    legend

    % Draw the curve of first 30% data of each pose
    figure(3)
    plot(first_retime,first_re,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(first_irtime,first_ir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('First 30% of UpLoBa Angle - Continuous'))
    legend

    figure(4)
    plot(data_retime,basere,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime,baseir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Fit line of UpLoBa Angle - Continuous'))
    legend

    figure(5)
    plot(peak_re,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(peak_ir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Peak of UpLoBa Angle - Continuous'))
    legend
end

saveas(figure(1),'UpLoBa Angle of Irregular Pose - Continuous.png');
saveas(figure(2),'Top 5% of UpLoBa Angle of Irregular Pose - Continuous.png');
saveas(figure(3),'First 30% of UpLoBa Angle - Continuous.png');
saveas(figure(4),'Fit line of UpLoBa Angle - Continuous.png');
saveas(figure(5),'Peak of UpLoBa Angle - Continuous.png');
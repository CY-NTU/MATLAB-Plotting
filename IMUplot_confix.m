clear; clc;
close all;

samplerate = 333;
sampleinterval = 1/samplerate;
colength = num2str('3000');
halfwindow = 150;

colororder_mix = ["#F70000";"#62A9FF";"#B9264F";"#6A6AFF";"#FF7575";"#8C8CFF";"#FF5353";"#9191FF";"#DD597D";"#A095EE"];

re_topalign_UM = [];
ir_topalign_UM = [];
re_peakalign_UM = [];
ir_peakalign_UM = [];
re_topalign_ML = [];
ir_topalign_ML = [];
re_peakalign_ML = [];
ir_peakalign_ML = [];
re_topalign_UL = [];
ir_topalign_UL = [];
re_peakalign_UL = [];
ir_peakalign_UL = [];
header_topre = [];
header_topir = [];
header_peakre = [];
header_peakir = [];

% Load the CSV file
for cnt = 11:13
    no = num2str(cnt);
    ref = strcat('xre', no, '.csv');
    irf = strcat('xir', no, '.csv');
    range_angUM = strcat('B1:B', colength);
    range_angML = strcat('C1:C', colength);
    range_angUL = strcat('D1:D', colength);
    
    angUM_re = readmatrix(ref, 'Range', range_angUM);
    angUM_re = lowpass(angUM_re,2,samplerate);
    angUM_ir = readmatrix(irf, 'Range', range_angUM);
    angUM_ir = lowpass(angUM_ir,2,samplerate);
    angML_re = readmatrix(ref, 'Range', range_angML);
    angML_re = lowpass(angML_re,2,samplerate);
    angML_ir = readmatrix(irf, 'Range', range_angML);
    angML_ir = lowpass(angML_ir,2,samplerate);
    angUL_re = readmatrix(ref, 'Range', range_angUL);
    angUL_re = lowpass(angUL_re,2,samplerate);
    angUL_ir = readmatrix(irf, 'Range', range_angUL);
    angUL_ir = lowpass(angUL_ir,2,samplerate);

    data_retime = 1:str2double(colength);
    data_retime = data_retime';
    data_retime = data_retime * sampleinterval;
    data_irtime = 1:str2double(colength);
    data_irtime = data_irtime';
    data_irtime = data_irtime * sampleinterval;
    lre = length(angUM_re);
    lir = length(angUM_ir);

    if lre < str2double(colength)
        angUM_re(lre+1 : str2double(colength)) = 0;
        angML_re(lre+1 : str2double(colength)) = 0;
        angUL_re(lre+1 : str2double(colength)) = 0;
    end

    if lir < str2double(colength)
        angUM_ir(lir+1 : str2double(colength)) = 0;
        angML_ir(lir+1 : str2double(colength)) = 0;
        angUL_ir(lir+1 : str2double(colength)) = 0;
    end

    % Let the origin data minus fit line to eliminate shift
    for i = 1 : lre
        pre_UM = polyfit(data_retime,angUM_re,5);
        basere_UM = polyval(pre_UM,data_retime);
        angUM_re(i) = angUM_re(i) - basere_UM(i);

        pre_ML = polyfit(data_retime,angML_re,5);
        basere_ML = polyval(pre_ML,data_retime);
        angML_re(i) = angML_re(i) - basere_ML(i);

        pre_UL = polyfit(data_retime,angUL_re,5);
        basere_UL = polyval(pre_UL,data_retime);
        angUL_re(i) = angUL_re(i) - basere_UL(i);
    end
    
    for j = 1 : lir
        pir_UM = polyfit(data_irtime,angUM_ir,5);
        baseir_UM = polyval(pir_UM,data_irtime);
        angUM_ir(i) = angUM_ir(i) - baseir_UM(i);

        pir_ML = polyfit(data_irtime,angML_ir,5);
        baseir_ML = polyval(pir_ML,data_irtime);
        angML_ir(i) = angML_ir(i) - baseir_ML(i);

        pir_UL = polyfit(data_irtime,angUL_ir,5);
        baseir_UL = polyval(pir_UL,data_irtime);
        angUL_ir(i) = angUL_ir(i) - baseir_UL(i);
    end

    % Smooth the curve
    angUM_re = smooth(data_retime,angUM_re,0.1,'rloess');
    angUM_ir = smooth(data_irtime,angUM_ir,0.1,'rloess');
    angML_re = smooth(data_retime,angML_re,0.1,'rloess');
    angML_ir = smooth(data_irtime,angML_ir,0.1,'rloess');
    angUL_re = smooth(data_retime,angUL_re,0.1,'rloess');
    angUL_ir = smooth(data_irtime,angUL_ir,0.1,'rloess');

    % Extract the first 30% largest values from the column
    first_UMre = angUM_re(1:round(0.3*lre));
    first_MLre = angML_re(1:round(0.3*lre));
    first_ULre = angUL_re(1:round(0.3*lre));
    first_retime = data_retime(1:round(0.3*lre));

    first_UMir = angUM_ir(1:round(0.3*lir));
    first_MLir = angML_ir(1:round(0.3*lir));
    first_ULir = angUL_ir(1:round(0.3*lir));
    first_irtime = data_irtime(1:round(0.3*lir));

    % Extract the peak cycle from the dataset 
    [~, pindex_UMre] = max(abs(angUM_re));
    [~, pindex_MLre] = max(abs(angML_re));
    [~, pindex_ULre] = max(abs(angUL_re));
%     [pks, pindex] = findpeaks(data_ang,'MinPeakProminence',1,'Annotate','extents');
    start_index_UMre = pindex_UMre - halfwindow;
    end_index_UMre = pindex_UMre + halfwindow;
    start_index_MLre = pindex_MLre - halfwindow;
    end_index_MLre = pindex_MLre + halfwindow;
    start_index_ULre = pindex_ULre - halfwindow;
    end_index_ULre = pindex_ULre + halfwindow;

    compare_UMre = [end_index_UMre,length(angUM_re)];
    end_index_UMre = min(compare_UMre);
    compare_MLre = [end_index_MLre,length(angML_re)];
    end_index_MLre = min(compare_MLre);
    compare_ULre = [end_index_ULre,length(angUL_re)];
    end_index_ULre = min(compare_ULre);

    peak_UMre = angUM_re(start_index_UMre : end_index_UMre);
    peak_MLre = angML_re(start_index_MLre : end_index_MLre);
    peak_ULre = angUL_re(start_index_ULre : end_index_ULre);

    [~, pindex_UMir] = max(abs(angUM_ir));
    [~, pindex_MLir] = max(abs(angML_ir));
    [~, pindex_ULir] = max(abs(angUL_ir));
%     [pks, pindex] = findpeaks(data_ang,'MinPeakProminence',1,'Annotate','extents');
    start_index_UMir = pindex_UMir - halfwindow;
    end_index_UMir = pindex_UMir + halfwindow;
    start_index_MLir = pindex_MLir - halfwindow;
    end_index_MLir = pindex_MLir + halfwindow;
    start_index_ULir = pindex_ULir - halfwindow;
    end_index_ULir = pindex_ULir + halfwindow;

    compair_UMir = [end_index_UMir,length(angUM_ir)];
    end_index_UMir = min(compair_UMir);
    compair_MLir = [end_index_MLir,length(angML_ir)];
    end_index_MLir = min(compair_MLir);
    compair_ULir = [end_index_ULir,length(angUL_ir)];
    end_index_ULir = min(compair_ULir);

    peak_UMir = angUM_ir(start_index_UMir : end_index_UMir);
    peak_MLir = angML_ir(start_index_MLir : end_index_MLir);
    peak_ULir = angUL_ir(start_index_ULir : end_index_ULir);

    re_peakalign_UM = [re_peakalign_UM,peak_UMre];
    ir_peakalign_UM = [ir_peakalign_UM,peak_UMir];
    re_peakalign_ML = [re_peakalign_ML,peak_MLre];
    ir_peakalign_ML = [ir_peakalign_ML,peak_MLir];
    re_peakalign_UL = [re_peakalign_UL,peak_ULre];
    ir_peakalign_UL = [ir_peakalign_UL,peak_ULir];
%     re_peakalign(:,cnt) = peak_re;
%     ir_peakalign(:,cnt) = peak_ir;
    
    % Extract the top 5% largest values from the dataset
    sorted_col_UMre = sort(abs(angUM_re),'descend');
    n_values_UMre = round(0.05 * length(sorted_col_UMre));
    top_5percent_UMre = sorted_col_UMre(1:n_values_UMre);

    sorted_col_UMir = sort(abs(angUM_ir),'descend');
    n_values_UMir = round(0.05 * length(sorted_col_UMir));
    top_5percent_UMir = sorted_col_UMir(1:n_values_UMir);

    re_topalign_UM = [re_topalign_UM,top_5percent_UMre];
    ir_topalign_UM = [ir_topalign_UM,top_5percent_UMir];
%     re_topalign(:,cnt) = top_5percent_re;
%     ir_topalign(:,cnt) = top_5percent_ir;

    sorted_col_MLre = sort(abs(angML_re),'descend');
    n_values_MLre = round(0.05 * length(sorted_col_MLre));
    top_5percent_MLre = sorted_col_MLre(1:n_values_MLre);

    sorted_col_MLir = sort(abs(angML_ir),'descend');
    n_values_MLir = round(0.05 * length(sorted_col_MLir));
    top_5percent_MLir = sorted_col_MLir(1:n_values_MLir);

    re_topalign_ML = [re_topalign_ML,top_5percent_MLre];
    ir_topalign_ML = [ir_topalign_ML,top_5percent_MLir];

    sorted_col_ULre = sort(abs(angUL_re),'descend');
    n_values_ULre = round(0.05 * length(sorted_col_ULre));
    top_5percent_ULre = sorted_col_ULre(1:n_values_ULre);

    sorted_col_ULir = sort(abs(angUL_ir),'descend');
    n_values_ULir = round(0.05 * length(sorted_col_ULir));
    top_5percent_ULir = sorted_col_ULir(1:n_values_ULir);

    re_topalign_UL = [re_topalign_UL,top_5percent_ULre];
    ir_topalign_UL = [ir_topalign_UL,top_5percent_ULir];

    col_topre = {strcat('re_topalign_UM',no),strcat('re_topalign_ML',no),strcat('re_topalign_UL',no)};
    header_topre = [header_topre,col_topre];
    col_topir = {strcat('ir_topalign_UM',no),strcat('ir_topalign_ML',no),strcat('ir_topalign_UL',no)};
    header_topir = [header_topir,col_topir];
    col_peakre = {strcat('re_peakalign_UM',no),strcat('re_peakalign_ML',no),strcat('re_peakalign_UL',no)};
    header_peakre = [header_peakre,col_peakre];
    col_peakir = {strcat('ir_peakalign_UM',no),strcat('ir_peakalign_ML',no),strcat('ir_peakalign_UL',no)};
    header_peakir = [header_peakir,col_peakir];

    % Draw the curve of top 5% data for each pose
    figure(1)
    plot(top_5percent_UMre, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(top_5percent_UMir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title('Top 5% of Up-Mid Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

    figure(2)
    plot(peak_UMre, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(peak_UMir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title('Peak Cycle of Up-Mid Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

    figure(3)
    plot(data_retime, angUM_re, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime, angUM_ir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Up-Mid Angle'))
    legend('Location','northeastoutside','Box','off')

    figure(4)
    plot(first_retime,first_UMre,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(first_irtime,first_UMir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('First 30% of Up-Mid Angle - Continuous'))
    legend('Location','northeastoutside','Box','off')

    figure(5)
    plot(data_retime,basere_UM,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime,baseir_UM,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Fit line of Up-Mid Angle - Continuous'))
    legend('Location','northeastoutside','Box','off')

    figure(6)
    plot(top_5percent_MLre, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(top_5percent_MLir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title('Top 5% of Mid-Low Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

    figure(7)
    plot(peak_MLre, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(peak_MLir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title('Peak Cycle of Mid-Low Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

    figure(8)
    plot(data_retime, angML_re, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime, angML_ir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Mid-Low Angle'))
    legend('Location','northeastoutside','Box','off')

    figure(9)
    plot(first_retime,first_MLre,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(first_irtime,first_MLir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('First 30% of Mid-Low Angle - Continuous'))
    legend('Location','northeastoutside','Box','off')

    figure(10)
    plot(data_retime,basere_ML,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime,baseir_ML,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Fit line of Mid-Low Angle - Continuous'))
    legend('Location','northeastoutside','Box','off')

    figure(11)
    plot(top_5percent_ULre, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(top_5percent_ULir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title('Top 5% of Up-Low Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

    figure(12)
    plot(peak_ULre, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(peak_ULir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title('Peak Cycle of Up-Low Angle for Different Pose')
    legend('Location','northeastoutside','Box','off')

    figure(13)
    plot(data_retime, angUL_re, 'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime, angUL_ir, 'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Up-Low Angle'))
    legend('Location','northeastoutside','Box','off')

    figure(14)
    plot(first_retime,first_ULre,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(first_irtime,first_ULir,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('First 30% of Up-Low Angle - Continuous'))
    legend('Location','northeastoutside','Box','off')

    figure(15)
    plot(data_retime,basere_UL,'LineWidth',1.5,'DisplayName',strcat('re',no))
    hold on
    plot(data_irtime,baseir_UL,'LineWidth',1.5,'DisplayName',strcat('ir',no))
    colororder(colororder_mix)
    set(gcf,'Position',[50,50,1000,750])
    title(strcat('Fit line of Up-Low Angle - Continuous'))
    legend('Location','northeastoutside','Box','off')

end

saveas(figure(1),'Top 5% of Up-Mid Angle for Different Pose.png')
saveas(figure(2),'Peak Cycle of Up-Mid Angle for Different Pose.png')
saveas(figure(3),'Up-Mid Angle.png')
saveas(figure(4),'First 30% of Up-Mid Angle - Continuous.png')
saveas(figure(5),'Fit line of Up-Mid Angle - Continuous.png')
saveas(figure(6),'Top 5% of Mid-Low Angle for Different Pose.png')
saveas(figure(7),'Peak Cycle of Mid-Low Angle for Different Pose.png')
saveas(figure(8),'Mid-Low Angle.png')
saveas(figure(9),'First 30% of Mid_Low Angle - Continuous.png')
saveas(figure(10),'Fit line of Mid_Low Angle - Continuous.png')
saveas(figure(11),'Top 5% of Up-Low Angle for Different Pose.png')
saveas(figure(12),'Peak Cycle of Up-Low Angle for Different Pose.png')
saveas(figure(13),'Up-Low Angle.png')
saveas(figure(14),'First 30% of Up_Low Angle - Continuous.png')
saveas(figure(15),'Fit line of Up_Low Angle - Continuous.png')

% Write the extracted values to a new CSV file
filename_re = 're_top5.csv';
writecell(header_topre, filename_re);
writematrix([re_topalign_UM,re_topalign_ML,re_topalign_UL], filename_re,'WriteMode', 'append');
filename_ir = 'ir_top5.csv';
writecell(header_topir, filename_ir);
writematrix([ir_topalign_UM,ir_topalign_ML,ir_topalign_UL], filename_ir,'WriteMode', 'append');
fname_re = 're_peak.csv';
writecell(header_peakre, fname_re);
writematrix([re_peakalign_UM,re_peakalign_ML,re_peakalign_UL], fname_re,'WriteMode', 'append');
fname_ir = 'ir_peak.csv';
writecell(header_peakir, fname_ir);
writematrix([ir_peakalign_UM,ir_peakalign_ML,ir_peakalign_UL], fname_ir,'WriteMode', 'append');
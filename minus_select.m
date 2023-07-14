clear; clc;
close all;

date = '230413';
state = 'bre';
colength = num2str('20000');

data_align = [];

figure()
hold on 

% Load the CSV file
for cnt = 1:15
    no = num2str(cnt);
    file = strcat(date, '_', state, no, '.csv');
    [num_rows, num_cols] = size(file);
%     range_UpBaRo = 'C8:C10000';
%     range_LoBaRo = 'R8:R10000';
    range_UpBaRo = strcat('R8:R',colength);
    range_LoBaRo = strcat('C8:C',colength);
    data_UpBa = readmatrix(file, 'Range', range_UpBaRo);
    data_LoBa = readmatrix(file, 'Range', range_LoBaRo);
    data_UpBa = lowpass(data_UpBa,4,240);
    data_LoBa = lowpass(data_LoBa,4,240);
    data_minus = zeros(num_rows);
    for i = 1:length(data_LoBa)
        data_minus(i) = data_UpBa(i) - data_LoBa(i);
    end

    plot(data_minus,'LineWidth',1.5,'DisplayName',strcat(state,no))
    
    % Extract the top 5% largest values from the column
    sorted_col = sort(abs(data_minus),'descend');
    n_values = round(0.05 * length(sorted_col));
    top_5_percent = sorted_col(1:n_values);
    top_5_percent = top_5_percent';

    data_align = horzcat(data_align,top_5_percent);

    % Write the extracted values to a new CSV file
    filename = strcat(state, no, '_minus_top5.csv');
    writematrix(top_5_percent, filename);
    fname = strcat('aligned_',state,'_minus_top5.csv');
    writematrix(data_align, fname);
end

hold off
title(strcat('UpLo-Rigidbody Rotation - ',state))
legend
ax_f = gcf;
exportgraphics(ax_f, strcat(state,'_RoMinus.jpg'))
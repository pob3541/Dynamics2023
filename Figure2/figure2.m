%% Plot the raw psychometric and chronometric curves
% Load the data from the Mat files
%
% Fig2_MonkeyT_data.mat
% Fig2_MonkeyO_data.mat
% 
% These are structures with the number of sessions.

clear
close all

%Load data for both monkeys
load('Fig2_MonkeyT_data.mat');
load('Fig2_MonkeyO_data.mat');

%Plot the psychometric and RT curves for both monkeys 
forExcelT = plotPsychAndChrono(figTData);
writetable(forExcelT.tablePsych,'fig2data.xls','FileType','spreadsheet','Sheet','fig.2d-top');
writetable(forExcelT.tableChrono,'fig2data.xls','FileType','spreadsheet','Sheet','fig.2e-top');

forExcelO = plotPsychAndChrono(figOData);
writetable(forExcelO.tablePsych,'fig2data.xls','FileType','spreadsheet','Sheet','fig.2d-bottom');
writetable(forExcelO.tableChrono,'fig2data.xls','FileType','spreadsheet','Sheet','fig.2e-bottom');

% Plot boxplots of RT vs. Coherence for both monkeys

figure(1);
width = 0.4;
ax = axes('position',[0.05 0.05 width width]);
TT = drawRTboxplot(figTData, ax);
writetable(TT, 'fig.2f-top.csv');


figure(2);
width = 0.4;
ax = axes('position',[0.05 0.05 width width]);
TO = drawRTboxplot(figOData, ax);
writetable(TO, 'fig.2f-bottom.csv');




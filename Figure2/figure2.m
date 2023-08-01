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
plotPsychAndChrono(figTData);  
plotPsychAndChrono(figOData);

% Plot boxplots of RT vs. Coherence for both monkeys

figure(1);
width = 0.4;
ax = axes('position',[0.05 0.05 width width]);
drawRTboxplot(figTData, ax);

figure(2);
width = 0.4;
ax = axes('position',[0.05 0.05 width width]);
drawRTboxplot(figOData, ax);




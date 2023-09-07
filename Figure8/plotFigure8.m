% load data for Figure 8 & S9
load Figure8data.mat

% process data for Figure 8
[r] = POA(outcome); 

% 8a
r.plotComponents(); 

% 8b
r.plotTrajectories();

% 8c & e
r.plotKinet();

% 8d
r.plotDecoder();

%% plot Supplementary Figure 9

dataS9= outcome.pcaCohRT;
[pcDataS9]=calculatePCs_S9(dataS9);

% S9a
plotComponents_S9(pcDataS9)

% S9b
plotTrajectories_S9(pcDataS9)




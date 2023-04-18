%%
params.position = [ 0.1151    0.1620    0.3943    0.7593];
params.Color = 'k';
params.lineWidth = 2;
params.markerSize = 12;
params.CI = 2;
params.hAxesOffsetRT = 10;
params.hAxesOffsetPC = 5;

figOData = [];
figOData.monkey = 'O';
figOData.signedColorCoherence = 100*summary.signedCoherence;
figOData.thresholds = popsummaryAllS.thresholds;
figOData.combined = combinedAll;
figOData.rawdata.RT = summaryAllS.allRT;                  % Standard Error of accuracy
figOData.rawdata.pRed =  summaryAllS.pRed;
figOData.params = params;


plotPsychAndChrono(figOData);

save('-mat','Fig1_MonkeyO_data.mat','figOData');
%%

params.position = [ 0.1151    0.1620    0.3943    0.7593];
params.Color = 'k';
params.lineWidth = 2;
params.markerSize = 12;
params.CI = 2;
params.hAxesOffsetRT = 10;
params.hAxesOffsetPC = 5;

figTData = [];
figTData.monkey = 'T';
figTData.signedColorCoherence = 100*summary.signedCoherence;
figTData.thresholds = popsummaryAllS.thresholds;
figTData.combined = combinedAll;
figTData.rawdata.RT = summaryAllS.allRT;                  % Standard Error of accuracy
figTData.rawdata.pRed =  summaryAllS.pRed;
figTData.params = params;


plotPsychAndChrono(figTData);

save('-mat','Fig1_MonkeyT_data.mat','figTData');


%%
clear all
load('Fig1_MonkeyT_data.mat');
plotPsychAndChrono(figTData);

load('Fig1_MonkeyO_data.mat');
plotPsychAndChrono(figOData);

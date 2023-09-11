
% cd into SuppFigures/Simulations

% select a kernel size for spike convolution
kernel = 0.02;
nNeurons = 200;
nTrials = 300;

% S3a
[ucFR, ucFRc, ucRT, tNew]=simulatePMdneurons('UnbiasedChoice',kernel,nNeurons,nTrials);

plotPCA(ucFRc, ucRT, tNew);
plotRegressionToRT(ucFR, ucRT, nTrials);
plotChoiceDecoding(ucFR, ucRT, nTrials);

% S3b
[bcFR, bcFRc, bcRT, tNew]=simulatePMdneurons('BiasedChoice',kernel,nNeurons,nTrials);

plotPCA(bcFRc, bcRT, tNew, nNeurons);
plotRegressionToRT(bcFR, bcRT, nTrials);
plotChoiceDecoding(bcFR, bcRT, nTrials);

% S3b
[rtFR, rtFRc, rtRT, tNew]=simulatePMdneurons('RT',kernel,nNeurons,nTrials);

plotPCA(rtFRc, rtRT, tNew, nNeurons);
plotRegressionToRT(rtFR, rtRT, nTrials);
plotChoiceDecoding(rtFR, rtRT, nTrials);

%% S21

nNeurons = 200;
nTrials = 300;

% S21a
kernel = 0.03;
[~, FRc_30, RT_30, tNew]=simulatePMdneurons('UnbiasedChoice',kernel,nNeurons,nTrials);

V_30 = plotPCA(FRc_30, RT_30, tNew, nNeurons);
plotSingleTrialPCA(FRc_30, tNew, nNeurons,V_30);

% S21b
kernel = 0.02;
[~, FRc_20, RT_20, tNew, nNeurons]=simulatePMdneurons('UnbiasedChoice',kernel,nNeurons,nTrials);

V_20 = plotPCA(FRc_20, RT_20, tNew, nNeurons);
plotSingleTrialPCA(FRc_20, tNew, nNeurons,V_20);







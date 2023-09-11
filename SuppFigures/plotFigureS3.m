% select a kernel size for spike convolution
kernel = 0.02;

% S3A
[FR, FRc, RT, tNew, nNeurons,nTrials]=simulatePMdneurons('UnbiasedChoice',kernel);

[~, ~, simData.PCA] = plotPCA(FRc, RT, tNew, nNeurons);
[simData.R2] = plotRegressionToRT(FR, RT, nTrials);
[simData.choice] = plotChoiceDecoding(FR, RT, nTrials);

% S3B
[FR, FRc, RT, tNew, nNeurons,nTrials]=simulatePMdneurons('BiasedChoice',kernel);

[~, ~, simData.PCA] = plotPCA(FRc, RT, tNew, nNeurons);
[simData.R2] = plotRegressionToRT(FR, RT, nTrials);
[simData.choice] = plotChoiceDecoding(FR, RT, nTrials);

% S3C
[FR, FRc, RT, tNew, nNeurons,nTrials]=simulatePMdneurons('RT',kernel);

[~, ~, simData.PCA] = plotPCA(FRc, RT, tNew, nNeurons);
[simData.R2] = plotRegressionToRT(FR, RT, nTrials);
[simData.choice] = plotChoiceDecoding(FR, RT, nTrials);

%% S21

% S21A
kernel = 0.02;
[~, FRc, RT, tNew, nNeurons]=simulatePMdneurons('UnbiasedChoice',kernel);

[V, ~, simData.PCA] = plotPCA(FRc, RT, tNew, nNeurons);
simTable.variance = plotSingleTrialPCA(FRc, tNew, nNeurons,V);
hold on
line(get(gca,'xlim'),0.9,'linestyle','--')



% S21B
kernel = 0.03;
[~, FRc, RT, tNew, nNeurons]=simulatePMdneurons('UnbiasedChoice',kernel);

[V, score, simData.PCA] = plotPCA(FRc, RT, tNew, nNeurons);
simTable.variance = plotSingleTrialPCA(FRc, tNew, nNeurons,V);
hold on
line(get(gca,'xlim'),0.9,'linestyle','--')

%%
% summarizeLDSsingle is identical to summarizeLDS except we do every other
% trial. Only for the stats do we hold out one trial and do fit on all
% other trials. It is a tad lazy just to change one variable but it is
% simple and easy.

files = dir('/net/derived/tianwang/LFADSdata/*.mat')
step = 100;

%%
sessionId = 40;
step = 100;
titles = {'Before Checkerboard Onset', 'After Checkerboard Onset'};
loc = [-.6 0];

for timeperiods = 1:2

    fprintf('\n %s', titles{timeperiods});

    currFileName = fullfile(files(sessionId).folder, files(sessionId).name);
    load(currFileName);


    forRRR = cat(3, forGPFA.dataStruct.RawData.Left, forGPFA.dataStruct.RawData.Right);
    RTs = [forGPFA.dataStruct.Info.Left.goodRTs'; forGPFA.dataStruct.Info.Right.goodRTs'];
    C = forGPFA.dataStruct.Info.Left.nSquares;
    C = abs(C-(225-C))./225;

    forRRR = forGPFA.dataStruct.RawData.Left;
    RTs = forGPFA.dataStruct.Info.Left.goodRTs';

    tAxis = [-600:1199]./1000;

    

    X1 = forRRR(1:step:end,:,:);
    tV = tAxis(1:step:end);
    if timeperiods == 2
        whichTs = tV > -0.05;
        selectT = tV > 0.1 & tV < 0.4;
    else
        whichTs = tV <= 0;
        selectT = tV <= -0.1;
    end


    R2 = [];

    dims = [2:2:10];
    stC = []; stO = [];
    for di = dims
        [R2(end+1), A1,origData, predData, RTv, trialIds] = summarizeLDSsingle(X1(whichTs,:,:),di,1,RTs, tV);
    end


    figure(40)

    subplot(2,1,timeperiods);
    cla;
    tOrig = tV(whichTs);
    tPred = tOrig(2:end);
    plot(tOrig, squeeze(origData(1:10:end,:,1))','-','color',[0.4 .4 0.4 0.4]);
    hold on;
    plot(tPred, squeeze(predData(1:10:end,:,1))','-','color',[1 .6 0.1 0.4],'linewidth',2)

    tLims = [tOrig(1) tPred(end)];
    set(gca,'visible','off');
    set(gcf,'renderer','painters');
    getAxesP(tLims, tLims(1):.2:tLims(end), 'Time (s)', -110, 2, [-100 250], [-100:50:250],'X_1',tLims(1)-0.1, 0.1);
    axis tight;

    
    text(loc(timeperiods), 250, titles{timeperiods}); 


end

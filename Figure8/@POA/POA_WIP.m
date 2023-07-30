classdef POA < handle

properties
signalplusnoise
behavior
shuffles
kinet
decode
noise
project
distance

metaData;
processingFlags;
end

methods

 function [r] = POA(outcome)
        r.initializeMetaData();
        r.initializeProcessingFlags();

        r.metaData.RT1=vertcat(outcome.errInd.PES_CCEC_RT{:});
        r.metaData.RT2=vertcat(r.metaData.RT1{:});
        r.metaData.RTlims = median(r.metaData.RT2);

        [r.signalplusnoise] = r.calculatePCs(permute(outcome.FR_EC_Rch_PCA_trunc, [3 4 2 1]));
        [r.project] = r.calculatePCs(permute(outcome.FR_EC_Rch_PCA_trunc, [3 4 2 1]),'projectFromMean',true,'projSpace',outcome.RTPCAeigenVs);


        params=getParams;
        RTlims=params.eRTpcL;
        [r.noise] = r.calculatePCs(outcome.noisePCA,'numConds',1:11,'RTlims',RTlims);

        r.calculatePOA_Bx(outcome);
        temp=r.signalplusnoise;
        r.kinet=r.calcSpeed(temp,'nDimensions',6);
        r.prepDecode(outcome)
        %distance calculation

        whichDim = [1:r.metaData.nDims];
        TrajIn = r.signalplusnoise.TrajIn;
        TrajOut = r.signalplusnoise.TrajOut;
        for z=1:length(TrajIn)
            r.distance(z).V = [sqrt(sum([TrajIn{z}(:,whichDim) - TrajOut{z}(:,whichDim)].^2,2))]';
        end

    end

% Plotting functions
plotKinet(r)
plotTrajectories(r,varargin)
plotVariance(r, varargin)
plotComponents(r,varargin)

function initializeMetaData(r)

    params = getParams; set(gcf,'visible','off');
    r.metaData.condColors = [0 1 0; 0 1 1; 1 0 0; 1 0 1];
    r.metaData.tMin = -0.4;
    r.metaData.whichConds = [1:4];
    r.metaData.t = linspace(-.6,1.2,1801);
    r.metaData.nComponents = 20;
    r.metaData.removeTime = 25;
    r.metaData.tMax = 0;
    r.metaData.OSess= [8 19 20 21 25 28 31 33 35 36 38 39 40:45 47:51 56 57 58 65]';
    r.metaData.TSess= [118:141]';
    r.metaData.sessions51=[r.metaData.OSess; r.metaData.TSess];
    r.metaData.nDims = 6;


end

function initializeProcessingFlags(r)
    r.processingFlags.subtractCCmean = false;
    r.processingFlags.meanSubtract = true;
    r.processingFlags.zScore = false;
    r.processingFlags.tColor = 'blue';

end

function [pcData] = calculatePCs(r,FR,varargin)

    [TinRates, ToutRates] = arrangeData(FR, 'subtractCCmean', r.processingFlags.subtractCCmean);

    XallIn = [];
    XallOut = [];
    tData = {};
    Lens = [];
    cnt = 1;

    projectFromMean=false;
    numConds=r.metaData.whichConds;
    t = r.metaData.t;
    tMin = r.metaData.tMin;
    RTlims=r.metaData.RTlims(1,:);
    projSpace=[];

    assignopts(who, varargin)

    O = RTlims - r.metaData.removeTime;



    for b= numConds
        tV = find(t > tMin & t < O(b)./1000);
        X = squeeze(TinRates(b,:,tV));
        XallIn = [XallIn; X'];
        X = squeeze(ToutRates(b,:,tV));
        XallOut = [XallOut; X'];
        Lens(cnt) = length(tV);
        tData{cnt} = t(tV);
        cnt = cnt + 1;
    end

    r.metaData.tMax = max(tData{end});


    Ndimensions = 200;
    [Data] = preprocessData(XallIn, XallOut, 'meanSubtract', r.processingFlags.meanSubtract, 'zScore', r.processingFlags.zScore, 'tColor', r.processingFlags.tColor);

    Ye = Data;
    Ye(isnan(Ye)) = nanmean(Ye(:));
    [eigenVectors, score,latentActual] = pca(Ye);
    pcData.varExplained = 100*latentActual./sum(latentActual);


    if projectFromMean
        eigenVectors=[];
        score = Ye*projSpace;
        pcData.varExplained = [];

    end
    [TrajIn, TrajOut] = chopScoreMatrix(score, Lens);

    pcData.TrajIn = TrajIn;
    pcData.TrajOut = TrajOut;
    pcData.eigenVectors = eigenVectors;
    pcData.projSpace=projSpace;
    pcData.score = score;
    pcData.latentActual = latentActual;
    pcData.tData = tData;
    pcData.covMatrix = cov(Ye);


end

function [r]=calcSubProj(r,varargin)
    numComps=6;
    assignopts(who,varargin)

    eV = r.project.projSpace(:,1:numComps);
    C=r.project.covMatrix;
    R = trace(eV'*C*eV);
    sumLatent2=sum(r.project.latentActual);
    r.project.varExplainedbySub =  R/sumLatent2;



end



function plotTrajectories(r, varargin)
    dimsToShow = [1 3 4];
    marker = 's';
    step = 20;
    lW = 2;
    m300size = 20;
    TrajIn = r.signalplusnoise.TrajIn;
    TrajOut = r.signalplusnoise.TrajOut;
    assignopts(who, varargin)
    f = figure('units','normalized','position',[0.2049 0.1292 0.6026 0.6394],'color',[1 1 1]);

    tData = r.signalplusnoise.tData;
    cValues = r.metaData.condColors;
    for k=1:4

        timePts = tData{k};
        zeroPt = find(timePts >-0.002 & timePts < 0.0,1,'first');
        movePt = find(timePts >.25,1,'first');

        S1 = TrajIn{k}(:,dimsToShow(1));
        S2 = TrajIn{k}(:,dimsToShow(2));
        S3 = TrajIn{k}(:,dimsToShow(3));
        X = 1:step:length(S1);

        hold on;
        plot3(S1(X),S2(X),S3(X),'color',cValues(k,:),'MarkerFaceColor', cValues(k,:),'MarkerEdgeColor','none','marker',marker,'markersize',10, 'linewidth',lW);
        if ~isempty(zeroPt)
            plot3(S1(zeroPt),S2(zeroPt),S3(zeroPt),'color',[0.8 0 0 0.5],'marker','o','markerFaceColor','r','markersize',m300size);
            plot3(S1(movePt),S2(movePt),S3(movePt),'color',cValues(k,:),'marker','d','markerFaceColor',cValues(k,:),'markersize',m300size);
        end

        S1 = TrajOut{k}(:,dimsToShow(1));
        S2 = TrajOut{k}(:,dimsToShow(2));
        S3 = TrajOut{k}(:,dimsToShow(3));
        plot3(S1,S2,S3,'color',cValues(k,:),'color', cValues(k,:),  'linewidth',lW,'linestyle','--');
        plot3(S1(X),S2(X),S3(X),'color',cValues(k,:),'MarkerFaceColor', cValues(k,:),'MarkerEdgeColor','none','marker',marker,'markersize',10, 'linewidth',lW,'linestyle','--');

        if ~isempty(zeroPt)
            plot3(S1(zeroPt),S2(zeroPt),S3(zeroPt),'color',[0.8 0 0 0.5],'marker','o','markerFaceColor','r','markersize',m300size);
            plot3(S1(movePt),S2(movePt),S3(movePt),'color',cValues(k,:),'marker','d','markerFaceColor',cValues(k,:),'markersize',m300size);
        end

    end

    str1 = sprintf('X%d', dimsToShow(1));
    str2 = sprintf('X%d', dimsToShow(2));
    str3 = sprintf('X%d', dimsToShow(3));
    xlabel(str1,'interpreter','latex');
    ylabel(str2);
    zlabel(str3);
    axis square;
    axis tight;
    clear ThreeVector;
    Tv = ThreeVector(gca);
    Tv.vectorLength = 2;
    Tv.axisInset = [5 5];


    text(-50, 52,'Correct','Color',cValues(1,:))
    text(-50, 50,'Post-correct','Color',cValues(2,:))
    text(-25, 52,'Error','Color',cValues(3,:))
    text(-25, 50,'Post-error','Color',cValues(4,:))


end


function calculatePOA_Bx(r,outcome)

    [outcome.errInd_seq2]=RTPES(outcome.Y,outcome.b,outcome.C,2,'session');

    r.behavior.CEC_RT=vertcat(outcome.errInd_seq2.PES_RT{:});
    r.behavior.CEC_RT=vertcat(r.behavior.CEC_RT{:});

    r.behavior.fastInd=find(sum(r.behavior.CEC_RT<200,2));
    r.behavior.CEC_RT_filt=r.behavior.CEC_RT;
    r.behavior.CEC_RT_filt(r.behavior.fastInd,:)=[];

end


function plotCEC(r)

    CEC_RTs=r.behavior.CEC_RT_filt;
    err=std(CEC_RTs)./sqrt(length(CEC_RTs));

    %Figure generation
    figure;
    errorbar([1,3],mean(CEC_RTs(:,[1,3])),2*err(:,[1,3]), 'go', 'LineWidth',3, 'MarkerSize',20,'CapSize',40); hold on;
    errorbar(2,mean(CEC_RTs(:,2)),2*err(:,2), 'ro', 'LineWidth',3, 'MarkerSize',20,'CapSize',40);
    plot(1:2,mean(CEC_RTs(:,1:2)),'-k','LineWidth',3);
    plot(2:3,mean(CEC_RTs(:,2:3)),'-k','LineWidth',3);


    ylabel('RT');xlabel('Trial Outcome');
    x_names={'C','E','C'};
    ymin=floor(min(mean(CEC_RTs)))-3;
    ymax=ceil(max(mean(CEC_RTs)))+3;
    ymid=(ymax+ymin)/2;

    axis off
    yLims=[ymin,ymax];
    yTicks=[ymin,ymid,ymax];
    tg = getTextLabel(1:3,{'C','E','C'},{'g','r','g'});
    xLims=[1, 3];
    xTicks= [];
    getAxesP(xLims, xTicks,4, min(mean(CEC_RTs))-10, 'Trial Outcome', yLims, yTicks, 0.1, 0.8, 'RT',[1 1],tg);
    %             axis square;
    axis tight;

end

function plotCCEC(r)

    % CC, EC behavioural data

    CCEC_RT=r.metaData.RT2;

    fastInd=find(sum(CCEC_RT<200,2));
    CCEC_RT_filt=CCEC_RT;
    CCEC_RT_filt(fastInd,:)=[];

    err=std(CCEC_RT_filt)./sqrt(length(CCEC_RT_filt));


    figure;
    errorbar(1:2,mean(CCEC_RT_filt(:,1:2)),2*err(1,1:2), 'g-o', 'LineWidth',3, 'MarkerSize',20,'CapSize',40); hold on;
    errorbar(3,mean(CCEC_RT_filt(:,3)),2*err(1,3), 'r-o', 'LineWidth',3, 'MarkerSize',20,'CapSize',40);
    errorbar(4,mean(CCEC_RT_filt(:,4)),2*err(1,4), 'g-o', 'LineWidth',3, 'MarkerSize',20,'CapSize',40);
    plot(3:4,mean(CCEC_RT_filt(:,3:4)),'-k','LineWidth',3);


    ylabel('RT');xlabel('Trial Outcome');
    %             title('PES')
    x_names={'C','C','E','C'};
    ymin=floor(min(mean(CCEC_RT_filt)));
    ymax=ceil(max(mean(CCEC_RT_filt)));
    drawRestrictedLines(2.5,[ymin ymax]);
    axis off
    yLims=[ymin,ymax];
    yTicks=[ymin,ymax];
    tg = getTextLabel(1:4,{'C','C','E','C'},{'g','g','r','g'});
    xLims=[1, 4];
    xTicks= [];
    getAxesP(xLims, xTicks,2, min(mean(CCEC_RT))-10, 'Trial Outcome', yLims, yTicks, 0.1, 0.8, 'RT',[1 1],tg);
    axis square;
    axis tight;




end

function calcShufEigVs(r,FR,numshuf)
    %Preallocate
    shufOutMat=zeros(1801,996,4,2,50);

    for shuf = 1:numshuf
        for n = 1:996
            shufOutMat(:,n,:,:,shuf)=FR(:,n,randperm(4),:);
        end
    end

    %Preallocate
    r.shuffles= r.calculatePCs(permute(shufOutMat(:,:,:,:,1), [3 4 2 1]));

    for shuf2 = 1:numshuf
        r.shuffles(shuf2)= r.calculatePCs(permute(shufOutMat(:,:,:,:,shuf2), [3 4 2 1])); %Properly rearranges the dimensions
    end

end

function Angles(r)

    load('~/Documents/Code/Old/DynamicsData/bootRTEigenVs.mat','bootRTEigenVs','RTeigenVs')
    OutcomeEVs=r.signalplusnoise.eigenVectors;
    BootAng=zeros(1,50);
    ShufAng=zeros(1,50);
    OutcomeShuffs=r.shuffles;


    for perms = 1:50
        coeffV = squeeze(bootRTEigenVs(perms,:,:));
        BootAng(perms) = subspace(coeffV(:,1:5), OutcomeEVs(:,1:6));
        ShufAng(perms) = subspace(RTeigenVs(:,1:5), OutcomeShuffs(perms).eigenVectors(:,1:5));
    end
    AllAngles=[rad2deg(BootAng)',rad2deg(ShufAng)'];
    minAA=floor(min(AllAngles(:)));
    maxAA=ceil(max(AllAngles(:)));
    figure;
    boxplot(AllAngles,'Notch','on','symbol','bo','Colors',['k' , 'r'])
    xlabels= getTextLabel([1 2],{'Bootstrap','Shuffle'},{'k','k'}) ;
    set(gca,'visible','off');
    hold on
    getAxesP([1 2],[],5,45,'',[minAA maxAA],[minAA 60 70 80 maxAA],0.1,0.8,['Subspace Angle (' char(176) ')'],[1 1],xlabels);
    axis square;
    axis tight;
end

function dataV = calcSpeed(r,temp, varargin)

    nDimensions = 6;
    assignopts(who, varargin);

    model = temp;
    Lens = [];
    for n=1:length(model.tData)
        Lens(n) = length(model.tData{n});
    end

    [maxLen, ind]= max(Lens);
    nNans = maxLen-Lens;
    rawData =[];
    rawData2 = [];





    for k=1:length(model.TrajIn)
        currData = model.TrajOut{k};
        NanMatrix = NaN*ones(nNans(k),nDimensions);
        rawData(:,k,:) = [currData(:,1:nDimensions); NanMatrix]';

        currData = model.TrajIn{k}; %r.signalplusnoise
        NanMatrix = NaN*ones(nNans(k),nDimensions);
        rawData2(:,k,:) = [currData(:,1:nDimensions); NanMatrix]';

    end
tValues = model.tData{ind};



dt=.01;

rawDataKinet = rawData(:,[2 3 1 4],1:10:end);
rawDataKinet2 = rawData2(:,[2 3 1 4],1:10:end);
[Sp, tVect, distAll] = KiNeT(rawDataKinet, dt);
[Sp2, ~, distAll2] = KiNeT(rawDataKinet2, dt);

dataV.V = mean(cat(3,Sp,Sp2),3);
dataV.tVect = tVect;
dataV.distancesAll = mean(cat(3,distAll,distAll2),3); %Taking absolute value here as there should be no negative values

end

function  plotKinet(r)

    %Speed
    lineColor = [0 1 1 ; 1 0 0;  0 1 0; 1 0 1];
    figure;
    for i = 1:4
        line(r.kinet.tVect,r.kinet.V(:,i)*1000-400, ...
            'Color',lineColor(i,:),'LineWidth',2);
    end
    time=getTextLabel([0 0.2 0.4 0.6 0.8], {'-400', '-200', 'Cue', '200', '400'}, {'k', 'k', 'b', 'k','k'});
    set(gca,'visible','off');
    hold on
    getAxesP([0 .8],[],50,-420,'Reference Time',[-400 500],[-400 -200 0 200 400],0.04,0,'Speed (ms)',[1 1],time);
    plot([0 0.81], [0.5 0.5],'k--','LineWidth',2)
    plot([0.4 0.4], [-400 400],'k--','LineWidth',2)
    axis square;
    axis tight;



    %Distance
    figure;
    for i = 1:4
        line(r.kinet.tVect,-r.kinet.distancesAll(:,i), ...
            'Color',lineColor(i,:),'LineWidth',2);
    end
    set(gca,'visible','off');
    hold on
    getAxesP([0 .81],[],4,-42,'Reference Time',[-40 40],[-40 -20 0 20 40],0.04,0,'Euclidean distance (a.u.)',[1 1],time);

    %                     plot([0 0.81], [0 0],'k--','LineWidth',2)
    plot([0.4 0.4], [-40 40],'k--','LineWidth',2)
    axis square;
    axis tight;
end

function prepDecode(r,outcome,varargin)


r.decode.sessions =  r.metaData.sessions51;
sessions=r.decode.sessions;

% bin spikes
for s=1:length(sessions)
    for c=1:length(outcome.spikeTimesMat{sessions(s)})
        if size(outcome.spikeTimesMat{sessions(s)}{c,1},3)>1 %# neurons sufficient per savetag

          

            bin = 50; %ms
            numBins=size(outcome.spikeTimesMat{sessions(s),1}{c,1}(100:1899,:,:),1)/bin;
            seshSTtr=size(outcome.spikeTimesMat{sessions(s),1}{c,1}); %# Trials/save tag
            A=squeeze(sum(reshape(outcome.spikeTimesMat{sessions(s),1}{c,1}(100:1899,:,:),bin,numBins,seshSTtr(2),[]),1));
            B=squeeze(sum(reshape(outcome.spikeTimesMat{sessions(s),1}{c,1}(110:1909,:,:),bin,numBins,seshSTtr(2),[]),1));
            r.decode.binnedSpikeTimes{s,1}{c,1}=reshape([A(:) B(:)]',size(A,1)+size(B,1), [], size(A,3));
        else
            %do nothing
        end
    end
end
end




function  calcDecode(r,outcome)

bins=size(r.decode.binnedSpikeTimes{1,1}{1,1},1); %numBins
sess = r.decode.sessions;

for s=1:length(sess)
    for c=1:length(r.decode.binnedSpikeTimes{s})
        if isempty(r.decode.binnedSpikeTimes{s}{c}) == 0

            preOutInd=outcome.errInd.errCorrMatchAll{sess(s),1}{c,1}(:,[1,3]);
            preOutInd=preOutInd(:);
            Y_train=outcome.Y_logic{sess(s),1}{c,1}(preOutInd);
            spInd=outcome.errInd.errCorrMatchAll{sess(s),1}{c,1}(:,[2,4]);
            spInd= spInd(:);

            for spkb = 1:bins

                spikes=squeeze(r.decode.binnedSpikeTimes{s,1}{c,1}(spkb,spInd,:));
                X_train=[ones(length(spikes),1),spikes];
                Mdl=fitclinear(X_train,Y_train,'Learner','logistic','Kfold',5);
                error = kfoldLoss(Mdl);
                r.decode.binAcc{s,1}{c,1}(spkb,1)=abs(1-error);
                r.decode.binAcc2{s,1}(spkb,c)=abs(1-error);

            end
        else
            %do nothing
        end
    end
end

r.decode.bins=bins;
end

function plotDecoder(r)

figure;
binAcc2=vertcat(r.decode.binAcc{:});
binAcc3=[binAcc2{:}];

xlin=linspace(-600,1200,r.decode.bins)';
y=mean(binAcc3,2)*100;
%                     plot(xlin,y,'LineWidth',3)
w=0;
err=std(binAcc3*100,w,2)./sqrt(size(binAcc3*100,1));
err=err*1;
L = y - err;
U = y + err;

hold on;
plot([-600 1200],[50 50],'--k','LineWidth',2)
shadedErrorBar(xlin,y,err)




%Make axes
ymin=floor(min([mean(binAcc3,2);(L/100)])*100);
ymax=ceil(max([mean(binAcc3,2);(U/100)])*100);
yLims=[ymin,ymax];
yTicks=[ymin, 50, ymax];
xLims=[-600, 1200];
xTicks= [-600 -300 0 300 600 900 1200];
plot([0 0],[ymin ymax],'--k','LineWidth',2)
axis off
getAxesP(xLims, xTicks,0.5, ymin-0.1, 'Time (ms)', yLims, yTicks, 0.1, -630, 'Accuracy (%)',[1 1]);
axis square;
axis tight;

end

function plotVariance(r, varargin)


    n = r.metaData.nComponents;
    assignopts(who, varargin);

    figure;
    plot(1:n,r.signalplusnoise.varExplained(1:n),'md-','markerfacecolor','m','markersize',6)
    hold on
    plot(1:n,r.noise.varExplained(1:n),'ko-','markerfacecolor',[0.9 0.9 0.9]-0.4,'markersize',6);
    set(gca,'visible','off');
    getAxesP([1 n],[1 n/2 n],5,-1,'Component',[0 70],[0 70],0,0,'Variance(%)',[1 1]);
    %getAxesP([1 n],[1:6 n],5,-2,'Component',[0 70],[0 70],0.5,0.5,'Variance(%)',[1 1]);

    line([1 n],[1 1],'color','k','linestyle','--');
    axis square;
    axis tight;

    cprintf('magenta', 'Variance from the first 6 components: %3.2f%% \n', sum(r.signalplusnoise.varExplained(1:6)))


end

function KinetV=permuteKinet(r, varargin)

    for p=1:size(r.shuffles,2)

        temp=r.shuffles(p);
        dataV = r.calcSpeed(temp);
        KinetV.V(p,:,:) = dataV.V;
        KinetV.tVect = dataV.tVect;
        KinetV.distancesAll(p,:,:) = dataV.distancesAll;



    end
end


end



end


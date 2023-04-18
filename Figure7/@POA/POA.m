classdef POA < handle
%
%
%
%
%
properties
signalplusnoise
MoveAlignsignalplusnoise
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

if isfield(outcome, 'errInd.PES_CCEC_RT') 
    r.metaData.RT1=vertcat(outcome.errInd.PES_CCEC_RT{:});
    r.metaData.RT2=vertcat(r.metaData.RT1{:});
    r.metaData.RTlims = median(r.metaData.RT2);
else
    for sess =1:length(outcome.CCE_ECC)
        for st= 1:length(outcome.CCE_ECC{sess,1})
            r.metaData.RT0{sess,1}{st,1}=outcome.b{sess,1}{st,1}(outcome.CCE_ECC{sess,1}{st,1});
        end
    end
    r.metaData.RT1=vertcat(r.metaData.RT0{:});
    r.metaData.RT2=vertcat(r.metaData.RT1{:});
    r.metaData.RTlims = median(r.metaData.RT2);
end

[r.signalplusnoise] = r.calculatePCs(permute(outcome.outcomePCA_trunc, [3 4 2 1]));
[r.project] = r.calculatePCs(permute(outcome.outcomePCA_trunc, [3 4 2 1]),'projectFromMean',true,'RTspace',outcome.RTPCAeigenVs,'RTcov',outcome.RTcovMatrix,'RTlatents',outcome.RTlatents);


temp=r.signalplusnoise;
r.kinet=r.calcSpeed(temp,'nDimensions',6);

if isfield(outcome, 'outcomePCA_trunc_Shuf')
    for shuf = 1: size(outcome.outcomePCAm_trunc_Shuf,5)
    pcData = r.calculatePCs(permute(outcome.outcomePCA_trunc_Shuf(:,:,:,:,shuf), [3 4 2 1]));
    dataV = r.calcSpeed(pcData);
    r.kinet.shuffV(:,:,shuf)=dataV.V;
    r.kinet.shuffDist(:,:,shuf)=dataV.distancesAll;
    end
else
    %
end

% if isfield(outcome, 'outcomePCAm_trunc')
%     for shuf = 1: size(outcome.outcomePCAm_trunc,5)
%     pcData = r.calculatePCs(permute(outcome.outcomePCAm_trunc(:,:,:,:,shuf), [3 4 2 1]));
%     dataV = r.calcSpeed(pcData);
%     r.kinet.BootV(:,:,shuf)=dataV.V;
%     r.kinet.BootDist(:,:,shuf)=dataV.distancesAll;
%     end
% else
%     %
% end




params=getParams;
RTlims=params.eRTpcL;

if isfield(outcome.noise,'varExplained')
    r.noise.varExplained = outcome.noise.varExplained;
elseif isfield(outcome,'noisePCA')
    [r.noise] = r.calculatePCs(outcome.noisePCA,'numConds',1:11,'RTlims',RTlims);
else
    %
end

%[r.signalplusnoise] = r.calculatePCs(permute(outcome.FR_CohRT4Dtrunc, [3 4 2 1]));

% r.calculatePOA_Bx(outcome);

% r.prepDecode(outcome)

whichDim = [1:r.metaData.nDims];
TrajIn = r.signalplusnoise.TrajIn;
TrajOut = r.signalplusnoise.TrajOut;
for z=1:length(TrajIn)
    r.distance(z).V = [sqrt(sum([TrajIn{z}(:,whichDim) - TrajOut{z}(:,whichDim)].^2,2))]';
end

if isfield(outcome, 'outcomePCAm_trunc') 
[r.MoveAlignsignalplusnoise] = r.calculatePCs(permute(outcome.outcomePCAm_trunc, [3 4 2 1]),'moveAlign',1);
TrajIn = r.MoveAlignsignalplusnoise.TrajIn;
TrajOut = r.MoveAlignsignalplusnoise.TrajOut;
for z=1:length(TrajIn)
    r.distance(z).VmoveAlign = [sqrt(sum([TrajIn{z}(:,whichDim) - TrajOut{z}(:,whichDim)].^2,2))]';
end
else
% do nothing
end

if isfield(outcome, 'outcomePCAm_trunc_Boot')
    for shuf = 1: size(outcome.outcomePCAm_trunc_Boot,5)
    pcData = r.calculatePCs(permute(outcome.outcomePCAm_trunc_Boot(:,:,:,:,shuf), [3 4 2 1]),'moveAlign',1);
    TrajIn = pcData.TrajIn;
    TrajOut = pcData.TrajOut;
    for z=1:length(TrajIn)
    r.distance(z).VmoveAlign_Boot(:,:,shuf) = [sqrt(sum([TrajIn{z}(:,whichDim) - TrajOut{z}(:,whichDim)].^2,2))]';
    end
    end
else
    %
end

end

% Plotting functions
%         plotKinet(r)
%         plotTrajectories(r,varargin)
%         plotVariance(r, varargin)
plotComponents(r,varargin)

function initializeMetaData(r)

params = getParams; set(gcf,'visible','off');
r.metaData.condColors = [0 1 0; 0 1 1; 1 0 0; 1 0 1];
r.metaData.tMin = -0.4;
r.metaData.whichConds = [1:4];
r.metaData.t = linspace(-.6,1.2,1801);
r.metaData.t_move = linspace(-.9,.9,1801);
r.metaData.nComponents = 20;
r.metaData.removeTime = 25;
r.metaData.tMax = 0;
%             r.metaData.OSess=[8 19 20 21 25 28 31:33 35 36 38:54 56:58 61:65];
r.metaData.OSess= [8 19 20 21 25 28 31 33 35 36 38 39 40:45 47:51 56 57 58 65]';
%             r.metaData.TSess= 52:75;
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

%             FR=permute(outcome.outcomePCA_trunc, [3 4 2 1]);
[TinRates, ToutRates] = arrangeData(FR, 'subtractCCmean', r.processingFlags.subtractCCmean);
%             RTspace=outcome.RTPCAeigenVs;

XallIn = [];
XallOut = [];
tData = {};
Lens = [];
cnt = 1;


% O = r.metaData.RTlims(1,:) - removeTime;
projectFromMean=false;
% projectFromRTSpace=false;
numConds=r.metaData.whichConds;
% t = r.metaData.t;
% tMin = r.metaData.tMin;
RTlims=r.metaData.RTlims(1,:);
RTspace=[];
RTcov=[];
RTlatents=[];
moveAlign=false;
assignopts(who, varargin)

if moveAlign == 0
    t = r.metaData.t;
    tMin = r.metaData.tMin;
else
    t = r.metaData.t_move;
    tMin = -.6;
end

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
% [Data] = preprocessData(XallIn, XallOut, 'meanSubtract', r.processingFlags.meanSubtract, 'zScore', r.processingFlags.zScore, 'tColor', r.processingFlags.tColor);
[Data] = preprocessData(XallIn, XallOut);

Ye = Data;
Ye(isnan(Ye)) = nanmean(Ye(:));
[eigenVectors, score,latentActual] = pca(Ye);
pcData.varExplained = 100*latentActual./sum(latentActual);


if projectFromMean
    eigenVectors=[];

    reducedRTspace=RTspace(:,1:6);

    score = Ye*reducedRTspace;
    %randomize rows and columns
%     randInd=randperm(length(reducedRTspace(:)));
%     randRTspace=reshape(reducedRTspace(randInd),[size(reducedRTspace,1),size(reducedRTspace,2)]);
    
    %randomize rows
    randInd=randperm(length(reducedRTspace));
    randRTspace=reducedRTspace(randInd,:);

    scoreRandom=Ye*randRTspace;
    
    [TrajIn, TrajOut] = chopScoreMatrix(score, Lens);
    [RandTrajIn, RandTrajOut] = chopScoreMatrix(scoreRandom, Lens);

    pcData.varExplained = [];
    pcData.TrajIn = TrajIn;
    pcData.TrajOut = TrajOut;
    pcData.RandTrajIn = RandTrajIn;
    pcData.RandTrajOut = RandTrajOut;
    pcData.randRTspace=randRTspace;

    pcData.eigenVectors = eigenVectors;
    pcData.RTspace=RTspace;
    pcData.score = score;
    pcData.scoreRandom = scoreRandom;
    pcData.OutcomeLatents = latentActual;
    pcData.RTLatents = RTlatents;
    pcData.tData = tData;
    pcData.OutcomeCov = cov(Ye);
    pcData.RTcov = RTcov;
    return;
end

[TrajIn, TrajOut] = chopScoreMatrix(score, Lens);
pcData.TrajIn = TrajIn;
pcData.TrajOut = TrajOut;
pcData.eigenVectors = eigenVectors;
pcData.RTspace=RTspace;
pcData.score = score;
pcData.latentActual = latentActual;
pcData.tData = tData;
pcData.covMatrix = cov(Ye);

end

function [r]=calcSubProj(r,varargin)
    numComps=6;
    assignopts(who,varargin)
    
    eV = r.signalplusnoise.eigenVectors(:,1:numComps);
    C=r.project.RTcov;
    R = trace(eV'*C*eV);
    sumLatent=sum(r.project.RTLatents);
    r.project.varExplainedbySubspace =  R/sumLatent;

%     eVrand = r.project.randRTspace;
%     Rrand = trace(eVrand'*C*eVrand);
%     r.project.varExplainedbyRandSubspace =  Rrand/sumLatent;
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
    %                  E = plot3(S1(X),S2(X),S3(X),'color',cValues(k,:),'MarkerFaceColor', [cValues(k,:)],'MarkerEdgeColor','none','marker',marker,'markersize',10);
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
% Tv.positionFrozenCorner = [0.22 0.2];
Tv.vectorLength = 2;
Tv.axisInset = [5 5];

%              set(gca,'CameraPosition',r.metaData.camPosition);

%              ax = gca;
%              ax.SortMethod = 'ChildOrder';

%               axes(aX(2));
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




function calcShufEigVs(r,FR,varargin)
%Preallocate
numshuf=50;
limitData=0;
assignopts(who, varargin)
shufOutMat=zeros(1801,996,4,2,numshuf);

for shuf = 1:numshuf
    for n = 1:996
        shufOutMat(:,n,:,:,shuf)=FR(:,n,randperm(4),:);
    end
end

%Preallocate
r.shuffles= r.calculatePCs(permute(shufOutMat(:,:,:,:,1), [3 4 2 1]));

if limitData == 1
    for shuf2 = 1:numshuf
        pcData=r.calculatePCs(permute(shufOutMat(:,:,:,:,shuf2), [3 4 2 1]));
        r.shuffles(shuf2).TrajIn=pcData.TrajIn;
        r.shuffles(shuf2).TrajOut=pcData.TrajOut;
        r.shuffles(shuf2).tData=pcData.tData;
    end
else

    for shuf2 = 1:numshuf
        r.shuffles(shuf2)= r.calculatePCs(permute(shufOutMat(:,:,:,:,shuf2), [3 4 2 1])); %Properly rearranges the dimensions
    end
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

%             lenV = RTmodel.Lens;
%             maxLen = max(RTmodel.Lens);



for k=1:length(model.TrajIn)
    currDataIn = model.TrajOut{k};
    NanMatrix = NaN*ones(nNans(k),nDimensions);
    rawData(:,k,:) = [currDataIn(:,1:nDimensions); NanMatrix]';

    currDataOut = model.TrajIn{k}; %r.signalplusnoise
    NanMatrix = NaN*ones(nNans(k),nDimensions);
    rawData2(:,k,:) = [currDataOut(:,1:nDimensions); NanMatrix]';

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
%             dataV.Sp=Sp;
%             dataV.Sp2=Sp2;
%             dataV.distAll=distAll;
%             dataV.distAll2=distAll2;
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

if isfield(r.kinet,'shuffledV')
kinetVsub=(r.kinet.V-r.kinet.V(:,3))*1000;
numshuf=size(r.kinet.shuffledV,3);
ShuffleV = r.kinet.shuffledV - repmat(r.kinet.shuffledV(:,:,3),[1 1 numshuf]);
% ShuffleV = mean(ShuffleV,3);
ShuffleV = mean(ShuffleV(:,[1 2 4], :),2);

ShuffleV =squeeze(ShuffleV);


figure; hold on;
line(r.kinet.tVect, prctile(1000*ShuffleV',[5 95])', 'Color', 'k','LineStyle','--');
for i = [1 2 4]
    line(r.kinet.tVect,kinetVsub(:,i), ...
        'Color',lineColor(i,:),'LineWidth',2);
%        line(r.kinet.tVect,1000*ShuffleV(:,i),'LineStyle','--');
%     line(r.kinet.tVect, prctile(squeeze(1000*ShuffleV(:,i,:))',[5 95])', 'Color', lineColor(i,:),'LineStyle','--');
end

time=getTextLabel([0 0.2 0.4 0.6 0.8], {'-400', '-200', 'Cue', '200', '400'}, {'k', 'k', 'b', 'k','k'});
ymin=min(min(kinetVsub));
ymax=max(max(kinetVsub));
set(gca,'visible','off');
hold on
getAxesP([0 .8],[],20,ymin-105,'Reference Time',[ymin-105 ymax+5],[ymin-105,-50,0,50,ymax+5],0.1,0,'Difference from reference (ms)',[1 1],time);
plot([0 0.81], [0.5 0.5],'k--','LineWidth',2)
plot([0.4 0.4], [ymin-105 ymax+5],'k--','LineWidth',2)
axis square;
axis tight;


% refline(0)

else
    %
end


% 
%  figure; plot(squeeze(mean(KinetV.V(:,:,:),1)-mean(KinetV.V(:,:,3),1)))
%  size(KinetV.V)

%getAxesP([-0.4 0.4]*1000,[-0.4:0.2:0.4]*1000,100,-420,'t_{Ref} (ms)',[-0.4 0.5]*1000,[-0.4:0.2:0.5]*1000,120,-420,'t (ms)',[1 1]);

% V = squeeze(nanmean(r.kinet.V+r.metaData.tMin)*1000);
% Ve = squeeze(nanstd(r.kinet.V+r.metaData.tMin)*1000);
% tVect = r.kinet.tVect + r.metaData.tMin;
%
%
% pa = [];
% li = [];
% for n=1:size(V,2)
%     [pa(n), li(n)] = ShadedError([tVect], squeeze(V(:,n))', squeeze(Ve(:,n)'));
%     hold on;
% end
% setLineColors(li);
% set(pa,'FaceAlpha',0.3);


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

%Determine which sessions to use based on num neurons
%                     numNeuronsInSess=5;
%                     assignopts(who,varargin);
%
%                     for sess = 1:size(outcome.spikeTimesMat,1)
%                         for c=1:length(outcome.spikeTimesMat{sess})
%                             MonkSess{sess,1}{c,1}=[size(outcome.spikeTimesMat{sess,1}{c,1},[2,3]),sess];
%                         end
%                     end
%
%                     SessCell=vertcat(MonkSess{:});
%                     SessRange=sortrows(cell2mat(SessCell),2,'descend');


%                     ToUse = SessRange(:,2)>=numNeuronsInSess;


%O_Sess=1:66;
%T_Sess=67:141;
%                      OSessions51=find(sum(store,2));
%                      TSessions51=118:141; %52:75 + 66 since T comes after
%                      sessions51= [OSessions51;TSessions51'];
%                      ToUse=sessions51;

%                     sessions=unique(SessRange(ToUse,3));
r.decode.sessions =  r.metaData.sessions51;
sessions=r.decode.sessions;
%                     r.decode.numNeurons=numNeuronsInSess;

% bin spikes
for s=1:length(sessions)
    for c=1:length(outcome.spikeTimesMat{sessions(s)})
        %if size(outcome.spikeTimesMat{sessions(s)}{c,1},3)>=r.decode.numNeurons %# neurons sufficient per savetag
        if size(outcome.spikeTimesMat{sessions(s)}{c,1},3)>1 %# neurons sufficient per savetag

            %for sess=1:length(outcome.spikeTimesMat)
            %for c=1:length(outcome.spikeTimesMat{sess})

            bin = 50; %ms
            %bin smoothin'
            numBins=size(outcome.spikeTimesMat{sessions(s),1}{c,1}(100:1899,:,:),1)/bin;
            seshSTtr=size(outcome.spikeTimesMat{sessions(s),1}{c,1}); %# Trials/save tag
            % r.decode.binnedSpikeTimes{sess,1}{c,1}=squeeze(sum(reshape(outcome.spikeTimesMat{sess,1}{c,1}(100:1899,:,:),bin,numBins,seshSTtr(2),[]),1));
            %r.decode.binnedSpTimesSh{sess,1}{c,1}=squeeze(sum(reshape(outcome.spikeTimesMat{sess,1}{c,1}(110:1909,:,:),bin,numBins,seshSTtr(2),[]),1));
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

%                     figure;
%                     ShadedError(xlin', y, err);
%                     plot(xlin,L,'k',xlin,U,'k')


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
getAxesP([1 n],[1 n/2 n],5,-1,'Component',[0 70], [0 10 20 30 40 50 60 70],1,0,'Variance (%)',[1 1]);
%getAxesP([1 n],[1:6 n],5,-2,'Component',[0 70],[0 70],0.5,0.5,'Variance(%)',[1 1]);

line([1 n],[1 1],'color','k','linestyle','--');
axis square;
axis tight;

cprintf('magenta', 'Variance from the first 6 components: %3.2f%% \n', sum(r.signalplusnoise.varExplained(1:6)))


end

function permuteKinet(r, varargin)

for p=1:size(r.shuffles,2)

    temp=r.shuffles(p);
    dataV = r.calcSpeed(temp);
    r.kinet.shuffledV(p,:,:) = dataV.V;
    r.kinet.shuffleddistancesAll(p,:,:) = dataV.distancesAll;


end
end


function pVals=calcKinetStats(r)

timesToAvg=[1:20;21:40;41:60;61:80]';
KinetV=r.kinet;

for o =[1 2 4]
    for t=1:4
        % mean real values
        rDist(t,o)=mean(KinetV.distancesAll(timesToAvg(:,t),o));
        rSpeed(t,o)=mean(KinetV.V(timesToAvg(:,t),o));
        % mean shuffle values
        shSpeed(:,t,o)=mean(squeeze(KinetV.shuffV(timesToAvg(:,t),o,:)),1)';
        shDist(:,t,o)=mean(squeeze(KinetV.shuffDist(timesToAvg(:,t),o,:)),1)';
    end
end
% tmp=mean(shDist,3);
%Compare each real averaged time block to shuffle to see which differ 
%(Can't do t-tests as these are esentially interpolated distributions)
for o=[1 2 4]
    %Distance results
    distLogical=rDist(:,o)'<shDist(:,:,o);
%     distLogical=rDist(:,o)'>tmp(:,o);
    pDist(:,o)=[sum(distLogical)/100]';

    %Speed results
    speedLogical=rSpeed(:,o)'<shSpeed(:,:,o);
    pSpeed(:,o)=[sum(speedLogical)/100]';
end
    %output values
    pVals.dist=pDist;
    pVals.speed=pSpeed;
end


% function pVals=bootKinetStats(r)
% 
% timesToAvg=[1:20;21:40;41:60;61:80]';
% KinetV=r.kinet;
% speedUnity=mean(reshape(KinetV.V(timesToAvg,3),[20 4]))';
% 
% for o =[1 2 4]
%     for t=1:4
%         % mean boot values
%         bootSpeed(:,t,o)=mean(squeeze(KinetV.BootV(timesToAvg(:,t),o,:)),1)';
%         bootDist(:,t,o)=mean(squeeze(KinetV.BootDist(timesToAvg(:,t),o,:)),1)';
%     end
% end
% 
% %Compare each boot averaged time block to "0" 
% %(Can't do t-tests as these are esentially interpolated distributions)
% for o=[1 2 4]
%     %Distance results
%     distLogical=bootDist(:,:,o)>0;
% %     pDist(:,o)=[sum(distLogical)/100]';
% 
%     %Speed results
%     speedLogical1=bootSpeed(:,:,o)-speedUnity';
%     speedLogical2=round(speedLogical1,2)>0;
%     speedLogical2=round(speedLogical1,2)<0;
%     sum(speedLogical2)
% %     pSpeed(:,o)=[sum(speedLogical)/100]';
% end
%     %output values
%     pVals.dist=pDist;
%     pVals.speed=pSpeed;
% end
% end








end
end


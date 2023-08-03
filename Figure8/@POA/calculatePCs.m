function [pcData] = calculatePCs(r,FR,varargin)
%
% calculate prinicipal components

%
[TinRates, ToutRates] = arrangeData(FR, 'subtractCCmean', r.processingFlags.subtractCCmean);

% Initialize variables
XallIn = [];
XallOut = [];
tData = cell(1,size(FR,1));
Lens = zeros(1,size(FR,1));
cnt = 1;

% adjust flags
projectFromMean=false;
numConds=r.metaData.whichConds;
RTlims=r.metaData.RTlims(1,:);
RTspace=[];
moveAlign=false;
assignopts(who, varargin)

% change time based on if movement or cue aligned
if moveAlign == 0
    t = r.metaData.t;
    tMin = r.metaData.tMin;
else
    t = r.metaData.t_move;
    tMin = -.6;
end

% sets RT limits
O = RTlims - r.metaData.removeTime;


% prepare dataset for pca
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

% perform pca
[Data] = preprocessData(XallIn, XallOut);
Ye = Data;
Ye(isnan(Ye)) = mean(Ye(:),'omitnan');

[eigenVectors, score,latentActual] = pca(Ye);
pcData.varExplained = 100*latentActual./sum(latentActual);
[TrajIn, TrajOut] = chopScoreMatrix(score, Lens);

% save the data in a structure
pcData.TrajIn = TrajIn;
pcData.TrajOut = TrajOut;
pcData.eigenVectors = eigenVectors;
pcData.RTspace=RTspace;
pcData.score = score;
pcData.latentActual = latentActual;
pcData.tData = tData;
pcData.covMatrix = cov(Ye);


%
% if projectFromMean
%
%     reducedRTspace=RTspace(:,1:6);
%
%     score = Ye*reducedRTspace;
%
%     %randomize rows
%     randInd=randperm(length(reducedRTspace));
%     randRTspace=reducedRTspace(randInd,:);
%
%     scoreRandom=Ye*randRTspace;
%
%     [TrajIn, TrajOut] = chopScoreMatrix(score, Lens);
%     [RandTrajIn, RandTrajOut] = chopScoreMatrix(scoreRandom, Lens);
%
%     pcData.varExplained = [];
%     pcData.TrajIn = TrajIn;
%     pcData.TrajOut = TrajOut;
%     pcData.RandTrajIn = RandTrajIn;
%     pcData.RandTrajOut = RandTrajOut;
%     pcData.randRTspace=randRTspace;
%
%     pcData.eigenVectors = [];
%     pcData.RTspace=RTspace;
%     pcData.score = score;
%     pcData.scoreRandom = scoreRandom;
%     pcData.OutcomeLatents = latentActual;
%     pcData.RTLatents = [];
%     pcData.tData = tData;
%     pcData.OutcomeCov = cov(Ye);
%     pcData.RTcov = [];
%     return;
% end


end
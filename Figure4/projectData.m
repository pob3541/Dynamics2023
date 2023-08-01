%%
r = N;

slopeV = [];
corrV = [];
corr2v = [];
latV = [];
actSlope = [];

bigD = [];
% 
for p=1:size(M.rt.bsFR,4)
    cprintf('yellow',sprintf('\n Bootstrap: %d', p));
    [temp] = r.calculatePCs(permute(squeeze(M.rt.bsFR(r.metaData.neuronIdx,:,:,p,:)),[2 3 1 4]));
    
    nDims = 6;
    for coh= 1:7
        [r.perCoh(coh).pcaData] = r.calculatePCsFromEachBS(permute(squeeze(M.rt.AllFR(r.metaData.neuronIdx,coh,:,:,:)),[2 3 1 4]),...
            'removeTime',25, 'projectFromMean', true, 'nDims', nDims,...
            'origEigenVectors', temp.eigenVectors);
    end
    
    [slopeV(p,:,:), bV, cohValues, forBigCorr, metaData] = r.calcInputsAndIC;
    
    corrValues(p).avgSel = metaData.avgSel;
    corrValues(p).latency = metaData.latency;
    corrValues(p).slope = metaData.slope;
    
    
    
    latV(p,:,:) = bV(:,:,1);
    actSlope(p,:,:) = bV(:,:,3);

    
    bs(p,:) = [metaData.avgSel.rIC metaData.avgSel.rCoh metaData.latency.rIC metaData.latency.rCoh metaData.slope.rIC metaData.slope.rCoh];
    bigD = [bigD; forBigCorr];
    
    [rp,po] = partialcorr(bigD(:,4), bigD(:,5), bigD(:,1))
    [rp,po] = partialcorr(bigD(:,2), bigD(:,5), bigD(:,1))
    [rp,po] = partialcorr(bigD(:,3), bigD(:,5), bigD(:,1))
    
    
    X = squeeze(nanmean(actSlope,3));
    % X = squeeze(nanmean(latV,3));
    cV = repmat(cohValues, size(X,1),1);
    
    [r1,pi] = corr(X(:), cV(:));
    
    close all
    
    3*squeeze(nanstd(slopeV))
    
    
end

%%
figure;
subplot(1,3,1);
Xnew = nanmean(latV,3);
cV = repmat(cohValues, size(Xnew,1),1);
[r,p] = corr(Xnew(:), cV(:))

errorbar(cohValues, nanmean(Xnew), 2*nanstd(Xnew));

subplot(1,3,2);
Xnew = nanmean(slopeV,3);
cV = repmat(cohValues, size(Xnew,1),1);
[r,p] = corr(Xnew(:), cV(:))

errorbar(cohValues, nanmean(Xnew), 2*nanstd(Xnew));


subplot(1,3,3);
Xnew = nanmean(actSlope,3);
cV = repmat(cohValues, size(Xnew,1),1);
[r,p] = corr(Xnew(:), cV(:))

errorbar(cohValues, nanmean(Xnew), 2*nanstd(Xnew));

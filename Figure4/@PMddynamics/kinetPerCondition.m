nDimensions = 7;
dt = 2;

Vall = [];
for b=[1:11]
    for k=1:7
        tempData.TrajIn{k} = N.perCoh(k).pcaData.TrajIn{b};
        tempData.TrajOut{k} = N.perCoh(k).pcaData.TrajOut{b};
        tempData.Lens(k) = size(tempData.TrajIn{1},1);
        tempData.tData{k} = N.perCoh(k).pcaData.tData{b};
    end
    
    
    RTmodel = tempData;
    lenV = RTmodel.Lens;
    maxLen = max(RTmodel.Lens);
    nNans = [maxLen-lenV];
    rawData =[];
    rawData2 = [];
    
    for k=1:length(RTmodel.TrajIn)
        currData = RTmodel.TrajOut{k};
        NanMatrix = NaN*ones(nNans(k),nDimensions);
        rawData(:,k,:) = [currData(:,1:nDimensions); NanMatrix]';
        
        currData = RTmodel.TrajIn{k};
        NanMatrix = NaN*ones(nNans(k),nDimensions);
        
        rawData2(:,k,:) = [currData(:,1:nDimensions); NanMatrix]';
        
    end
    tValues = RTmodel.tData{1};
    
    rawDataKinet = rawData(:,:,1:dt:end);
    tCorrected = tValues(1:dt:end);
    [V, tVect, distancesAll, dataV.addData] = KiNeT(rawDataKinet, .005);
    dataV.V = V;
    dataV.tVect = tVect;
    dataV.distancesAll = distancesAll;
    
    li = plot(tVect-0.4, V);
    setLineColors(li);
    
    rawDataKinet = rawData2(:,:,1:dt:end);
    tCorrected = tValues(1:dt:end);
    [V2, tVect, distancesAll, dataV.addData] = KiNeT(rawDataKinet, dt/1000);
    dataV.V = V;
    dataV.tVect = tVect;
    dataV.distancesAll = distancesAll;
    
    li = plot(tVect-0.4, V);
    setLineColors(li);
    
    tValid = tVect-0.4 > -0.2 & tVect-0.4 < 0.265;
    Vall(b,:,:) = [V(tValid,:)+V2(tValid,:)]/2;
end

%%



%%
X = squeeze(nanmean(Vall(1:end,:,:)));
X = X -repmat(X(:,4),[1 7]);

li = plot(X);
setLineColors(li);

plot(nanmean(X(12:22,:)),'ko-')
hold on
plot(nanmean(X(50:end,:)),'o-');



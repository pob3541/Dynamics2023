function dataV = calcSpeed(r, temp, varargin)
%
% whichDims = 7:12;
nDimensions = 6;
assignopts(who, varargin);

dt = r.metaData.dt;

temp.Lens = [];
for n=1:length(r.signalplusnoise.tData)
    temp.Lens(n) = length(r.signalplusnoise.tData{n});
end

RTmodel = temp;
lenV = RTmodel.Lens;
maxLen = max(RTmodel.Lens);
nNans = [maxLen-lenV];
rawData =[];
rawData2 = [];

for k=1:length(RTmodel.TrajIn)
    currData = RTmodel.TrajOut{k};
    NanMatrix = NaN*ones(nNans(k),nDimensions);
    rawData(:,k,:) = [currData(:,1:nDimensions); NanMatrix]';
%     NanMatrix = NaN*ones(nNans(k),length(whichDims));
%     rawData(:,k,:) = [currData(:,whichDims); NanMatrix]';
    
    currData = RTmodel.TrajIn{k};
    NanMatrix = NaN*ones(nNans(k),nDimensions);
    rawData2(:,k,:) = [currData(:,1:nDimensions); NanMatrix]';
%     NanMatrix = NaN*ones(nNans(k),length(whichDims));
%     rawData2(:,k,:) = [currData(:,whichDims); NanMatrix]';
    
end
tValues = RTmodel.tData{10};

rawDataKinet = rawData(:,:,1:dt:end);
tCorrected = tValues(1:dt:end);
[V1, tVect, distancesAll1, dataV.addData(1,:)] = KiNeT(rawDataKinet, dt./1000);

rawDataKinet = rawData(:,:,1:dt:end);
tCorrected = tValues(1:dt:end);
[V2, tVect, distancesAll2, dataV.addData(2,:)] = KiNeT(rawDataKinet, dt./1000);

V = (V1+V2)/2;

distancesAll = (distancesAll1 + distancesAll2)/2;

dataV.V = V;
dataV.tVect = tVect;
dataV.distancesAll = distancesAll;

rawData = rawData(:,:,1:dt:end);
rawData2 = rawData2(:,:,1:dt:end);
tCorrected = tValues(1:10:end);

Speed1 = squeeze(sqrt(sum((diff(rawData,1,3)).^2)))'./(dt./1000);
Speed2 = squeeze(sqrt(sum((diff(rawData2,1,3)).^2)))'./(dt./1000);

dataV.speed = [Speed1+Speed2]/2;
dataV.tSpeed = tCorrected(2:end)*1000;

end
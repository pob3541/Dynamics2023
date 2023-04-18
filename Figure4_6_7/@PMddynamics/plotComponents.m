function plotComponents(r, varargin)
% plots specified components and also euclidean distance for choice
%
% Chand, 30 Mar 2022
TrajIn = r.signalplusnoise.TrajIn;
TrajOut = r.signalplusnoise.TrajOut;
outcome=false;
assignopts(who,varargin)
cValues = r.metaData.condColors;
dimsToShow = [1:5];
whichDim = [1:r.metaData.nDims];
lW = 2;

% change this based on move

V = r.signalplusnoise.varExplained;
tData = r.signalplusnoise.tData;


f = figure('units','normalized','position',[0.2049 0.1292 0.6026 0.6394],'color',[1 1 1]);
aX(1) = axes('position',[0.05 0.55 0.22 0.4]);
aX(2) = axes('position',[0.35 0.55 0.22 0.4]);
aX(3) = axes('position',[0.65 0.55 0.22 0.4]);
aX(4) = axes('position',[0.05 0.09 0.22 0.4]);
aX(5) = axes('position',[0.35 0.09 0.22 0.4]);
aX(6) = axes('position',[0.65 0.09 0.22 0.4]);

MinMax = [];


for z=1:length(r.metaData.condColors) %11
    compCnt = 1;
    
    for f= dimsToShow
        axes(aX(compCnt));
        set(gca,'visible','off');
        li = plot(tData{z}*1000', TrajIn{z}(:,f)'); hold on;
        set(li,'color',cValues(z,:));
        li = plot(tData{z}*1000', TrajOut{z}(:,f)'); hold on;
        set(li,'color',cValues(z,:),'linestyle','--');
        hold on;
        Temp = [ min([TrajIn{z}(:,f); TrajOut{z}(:,f)]) max([TrajIn{z}(:,f); TrajOut{z}(:,f)])];
        MinMax(z,compCnt,:) = Temp;
        compCnt = compCnt + 1;
        %                     if z==1
        %                         text(20,12.5,sprintf('%3.2f%%',V(f)));
        %                     end
    end
    
    DistV = r.distance(z).V;
    DistV(DistV > 300) = NaN;
    
    
    
    axes(aX(6));
    hold on;
    if outcome
        li = plot(tData{z}*1000, DistV);
    else
        [~,li] = ShadedError(tData{z}*1000, nanmean(DistV), nanstd(DistV));
    end
    set(li,'color',cValues(z,:));
    
    tempT = tData{z}*1000;
    tIds = tempT > 125 & tempT < 375;
    
    dVal(z) = nanmean(nanmean(DistV(:,tIds)),2);
    
    Dist{z} = nanmean(DistV);
end

S1 = MinMax(:,:,1);
S1 = S1(:);

S2 = MinMax(:,:,2);
S2 = S2(:);

yLims = [floor(min(S1(:))) ceil(max(S2(:)))];

maxValues = 0;
% Now clean up the axes on it.
for z=1:5
    axes(aX(z));
    str1 = sprintf('Component : %d', dimsToShow(z));
    tMin = r.metaData.tMin;
    xTicks = [tMin*1000  200:200:500];
    xLims = [tMin*1000 r.metaData.tMax*1000];
    strValue = 'Check';
    
    text(20,yLims(2)-0.5,sprintf('%3.2f%%',V(z)));
    
    cTextLabels = getTextLabel(0,{strValue},{'b'});
    
    try
%         yTicks = yLims;
          yTicks = round(linspace(yLims(1),yLims(2),5));
        drawRestrictedLines(0,yLims,'lineStyle','--');
        if z == 4 || z == 5
            getAxesP(xLims, xTicks, 8.5, yLims(1), 'Time (ms)', yLims, yTicks, 60, xLims(1)-20, sprintf('PC_%d', dimsToShow(z)),[1 1],cTextLabels);
        else
            getAxesP(xLims, xTicks, 2, yLims(1), '', yLims, yTicks,60, xLims(1)-20, sprintf('PC_%d', dimsToShow(z)),[1 1],cTextLabels);
        end
    catch
    end
    axis tight; axis square;
end


hold on;
set(gca,'visible','off');
if outcome
    distMinMax = [min(DistV), max(DistV)];
else
    distMinMax(z,:) = [min(Dist{z}), max(Dist{z})];
end

axis tight; axis square;

axes(aX(6));
yLims = floor([min(distMinMax(:,1))-1 max(distMinMax(:,2))]) ;
% yTicks = [yLims(1) yLims(2)];
yTicks = round(linspace(yLims(1),yLims(2),5),0);
getAxesP(xLims, xTicks, 12.5, yLims(1), 'Time (ms)', yLims, round(yTicks), 100, xLims(1)-20, 'High D Distance',[1 1],cTextLabels);
% drawRestrictedLines(0,yLims,'lineStyle','--');
% drawRestrictedLines(-100:0,[82 85],'lineStyle','--');

axis tight; axis square;
set(gca,'visible','off');

if outcome == 0
[rV,pV] = corr(nanmean(r.metaData.RTlims)', dVal')
text(-380,95,sprintf('r = %3.2f',rV));
text(-380,90,sprintf('p = %3.2e',pV));

cbPos=[0.405 0.965];
cbSize=[0.1 0.01];
fSize=10;
cbLyPos=1.8;

custColorBar(r,cbPos,cbSize,fSize,cbLyPos)
else
    axes(aX(2));
    text(-400, 68,'Correct','Color',cValues(1,:))
    text(-400, 60,'Post-correct','Color',cValues(2,:))
    text(-200, 68,'Error','Color',cValues(3,:))
    text(-200, 60,'Post-error','Color',cValues(4,:))
end




end
function [CI, meanDist]=plotComponents(r, varargin)
% plots specified components and also euclidean distance for choice
%
%[CI, meanDist]=r.plotComponents(r, 'moveAlign',1)output doesnt work due to
%conflicting plotComponents
% Chand, 30 Mar 2022
TrajIn = r.signalplusnoise.TrajIn;
TrajOut = r.signalplusnoise.TrajOut;
outcome=true;
moveAlign=0;
assignopts(who,varargin)
cValues = r.metaData.condColors;
dimsToShow = [1:5];
whichDim = [1:r.metaData.nDims];
lW = 2;

if moveAlign ==0
    V = r.signalplusnoise.varExplained;
    tData = r.signalplusnoise.tData;
else
    TrajIn = r.MoveAlignsignalplusnoise.TrajIn;
    TrajOut = r.MoveAlignsignalplusnoise.TrajOut;
    V = r.MoveAlignsignalplusnoise.varExplained;
    tData = r.MoveAlignsignalplusnoise.tData;
end

f = figure('units','normalized','position',[0.2049 0.1292 0.6026 0.6394],'color',[1 1 1]);
aX(1) = axes('position',[0.05 0.55 0.22 0.4]);
aX(2) = axes('position',[0.35 0.55 0.22 0.4]);
aX(3) = axes('position',[0.65 0.55 0.22 0.4]);
aX(4) = axes('position',[0.05 0.09 0.22 0.4]);
aX(5) = axes('position',[0.35 0.09 0.22 0.4]);
aX(6) = axes('position',[0.65 0.09 0.22 0.4]);

% V = r.signalplusnoise.varExplained;
MinMax = [];


% tData = r.signalplusnoise.tData;

for z=1:length(r.metaData.condColors) %11
    compCnt = 1;

    if moveAlign ==0
        DistV = r.distance(z).V;
        tempEnd=size(TrajIn{z},1);
    else
        DistV = r.distance(z).VmoveAlign;
    tempEnd=700;
    tscore = tinv([0.025 0.975],length(1:tempEnd)-1);
%     CI = avgDistV + SEM*tscore;
    end
    DistV(DistV > 300) = NaN;
    DistV(DistV > 300) = NaN;
    
    for f= dimsToShow
        axes(aX(compCnt));
        set(gca,'visible','off');
        li = plot(tData{z}(1:tempEnd)*1000', TrajIn{z}(1:tempEnd,f)'); hold on;
        set(li,'color',cValues(z,:));
        li = plot(tData{z}(1:tempEnd)*1000', TrajOut{z}(1:tempEnd,f)'); hold on;
        set(li,'color',cValues(z,:),'linestyle','--');
        hold on;
        Temp = [ min([TrajIn{z}(:,f); TrajOut{z}(:,f)]) max([TrajIn{z}(:,f); TrajOut{z}(:,f)])];
        MinMax(z,compCnt,:) = Temp;
        compCnt = compCnt + 1;
        %                     if z==1
        %                         text(20,12.5,sprintf('%3.2f%%',V(f)));
        %                     end
    end
    


    
    axes(aX(6));
    hold on;
%     if outcome 
      if isfield(r.distance,'VmoveAlign_Boot') &&  moveAlign ==1
        DistV_boot=squeeze(r.distance(z).VmoveAlign_Boot);
        DistV_boot(DistV_boot > 300) = NaN;
        avgDistV=mean(DistV_boot,2,'omitnan');
        stdDistV=std(DistV_boot','omitnan');
        [~,li] = ShadedError(tData{z}(1:tempEnd)*1000, avgDistV(1:tempEnd)',stdDistV(1:tempEnd)*tscore(2));
        CI(:,:,z) = avgDistV(1:tempEnd)+stdDistV(1:tempEnd)'*tscore;
        meanDist(:,z)=avgDistV(1:tempEnd); 
        %make a running window to show the CI at 10 ms steps (non-overlapping) 
%       timeDist=-200:10:-30;
%       realtime=400:10:570;
%       overlap=10;

%       for ts= 1:length(timeDist)-1
%       time=timeDist(ts):timeDist(ts+1);
%       tPeriod=realtime(ts):realtime(ts+1); %
%   
%     DistV_boot=squeeze(r.distance(z).VmoveAlign_Boot);
%     DistV_boot(DistV_boot > 300) = NaN;
%     avgDistV=mean(DistV_boot(1:700,:),2,'omitnan');
%     x=avgDistV(tPeriod); 
%     SEM = std(x)/sqrt(length(x));               % Standard Error
%     tscore = tinv([0.025 0.975],length(x)-1);
%     avgCS(ts,z) = mean(x); % T-Score
%     CI(z,:,ts) = avgCS(ts,z) + tscore*SEM; 
%    
% 
%       y1=ones(length(time))*CI(z,1,ts);
%       y2=ones(length(time))*CI(z,2,ts);
%        plot(time,y1,'lineStyle','--','LineWidth',2,'Color',cValues(z,:))
%        plot(time,y2,'lineStyle','--','LineWidth',2,'Color',cValues(z,:))
%        
%       end

      else
        li = plot(tData{z}(1:tempEnd)*1000, DistV(1:tempEnd));
      end

%     else
%         [~,li] = ShadedError(tData{z}*1000, nanmean(DistV_boot), nanstd(DistV_boot));
%     end
    set(li,'color',cValues(z,:));
    
    tempT = tData{z}*1000;
    tIds = tempT > 125 & tempT < 375;
    
    dVal(z) = nanmean(nanmean(DistV(:,tIds)),2);
    
    Dist{z} = nanmean(DistV);
end
% if isfield(r.distance,'VmoveAlign_Boot') &&  moveAlign ==1
%       for ts= 1:length(timeDist)-1
%     text(timeDist(ts)+3,CI(4,2,ts)+2,num2str(ts))
%       end
% end

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
    
    if moveAlign ==0
    tMin = r.metaData.tMin;
    xLims = [tMin*1000 r.metaData.tMax*1000];
    xTicks = [tMin*1000  200:200:500];

    else
    tMin = -.6;
    xLims = [tMin*1000 .1*1000];
    xTicks = [tMin*1000:200:-100  100];

    end
    
    strValue = 'Check';
    
    text(20,yLims(2)-0.5,sprintf('%3.2f%%',V(z)));
    
    cTextLabels = getTextLabel(0,{strValue},{'b'});
    
    try
%         yTicks = yLims;
            yTicks = linspace(yLims(1),yLims(2),5);
        drawRestrictedLines(0,yLims,'lineStyle','--');
        if z == 4 || z == 5
            getAxesP(xLims, xTicks, 8.5, yLims(1), 'Time (ms)', yLims, yTicks, 50, xLims(1)-20, sprintf('PC_%d', dimsToShow(z)),[1 1],cTextLabels);
        else
            getAxesP(xLims, xTicks, 2, yLims(1), '', yLims, yTicks, 50, xLims(1)-20, sprintf('PC_%d', dimsToShow(z)),[1 1],cTextLabels);
        end
    catch
    end
    axis tight; axis square;
end


hold on;
set(gca,'visible','off');
% distMinMax(z,:) = [min(Dist{z}), max(Dist{z})]; %was z
% distMinMax = [min(vertcat(Dist{:})), max(vertcat(Dist{:}))]; 
distMinMax = [min(DistV), max(DistV)];
axis tight; axis square;

axes(aX(6));
yLims = floor([min(distMinMax(:,1))-1 max(distMinMax(:,2))]) ;
% yTicks = [yLims(1) yLims(2)];
yTicks = round(linspace(yLims(1),yLims(2),5),0);
getAxesP(xLims, xTicks, 5, yLims(1), 'Time (ms)', yLims, round(yTicks), 100, xLims(1)-20, 'High D Distance',[1 1],cTextLabels);
drawRestrictedLines(0,yLims,'lineStyle','--');
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
    text(-400, 64,'Post-correct','Color',cValues(2,:))
    text(-200, 68,'Error','Color',cValues(3,:))
    text(-200, 64,'Post-error','Color',cValues(4,:))
end




end

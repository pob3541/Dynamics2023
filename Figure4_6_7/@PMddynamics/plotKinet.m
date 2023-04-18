function plotKinet(r, varargin)
%
%   plots the results from the KiNeT analysis developed in the Jazayeri Lab
%   uses the kinet results computed previously in the class constructor.
%
% Chand, March 30th 2022
% 
assignopts(who,varargin)

figure('color',[1 1 1]);

V = squeeze(nanmean(r.kinet.V+r.metaData.tMin)*1000);
Ve = squeeze(nanstd(r.kinet.V+r.metaData.tMin)*1000);

tVect = r.kinet.tVect + r.metaData.tMin;
rawData = r.kinet.V + r.metaData.tMin;
tIdx = find(tVect>=-0.1,1,'first');

X = r.metaData.RTlims;
X = nanmean(X);
[rCorr,pCorr] = corr(squeeze(X)', squeeze(nanmean(rawData(:,tIdx,:))))


distancesAll = -squeeze(nanmean(r.kinet.distancesAll));
distancesE = squeeze(nanstd(r.kinet.distancesAll));
tSpeed = r.kinet.tSpeed;
speed = squeeze(nanmean(r.kinet.speed));
speedE = squeeze(nanstd(r.kinet.speed));

[rDist, pDist] = corr(squeeze(X)',squeeze(distancesAll(tIdx,:))')


subplot(3,2,1);
pa = [];
li = [];
for n=1:size(V,2)
    [pa(n), li(n)] = ShadedError([tVect]*1000, squeeze(V(:,n))', squeeze(Ve(:,n)'));
    hold on;
end
setLineColors(li);
set(pa,'FaceAlpha',0.3);
set(gca,'visible','on');
drawRestrictedLines(0,[-400 500]);
line([-400 400],[0 0],'color','k','linestyle','--');
hold on;
getAxesP([-0.4 0.4]*1000,[-0.4:0.2:0.4]*1000,100,-420,'t_{Ref} (ms)',[-0.4 0.5]*1000,[-0.4:0.2:0.5]*1000,120,-420,'t (ms)',[1 1]);
set(gca,'visible','off');
axis square;
axis tight;
% text(500,500,sprintf('r=%3.2f, p=%3.3f',rCorr, pCorr));
text(-380,400,sprintf('r = %3.2f',rCorr));
text(-380,330,sprintf('p = %3.2e',pCorr));

subplot(3,2,3);
RTl = r.metaData.RTlims(1,:);
RTh = r.metaData.RTlims(2,:);
params = getParams;

pa = [];
li = [];

for n=1:size(V,2)
    [pa(n), li(n)] = ShadedError([tVect]*1000, squeeze(distancesAll(:,n))', squeeze(distancesE(:,n))');
    hold on;
end
setLineColors(li);
set(pa,'FaceAlpha',0.3);

% X = plot(1000*[tVect], squeeze(distancesAll));
% setLineColors(X);
set(gca,'visible','on');
line([-400 400],[0 0],'color','k','linestyle','--');
set(gca,'visible','off');
hold on;
drawRestrictedLines(0,[-30 30]);
getAxesP([-0.4 0.4]*1000,[-0.4:0.2:0.4]*1000,5,-30,'t (s)',[-30 30],[-30:10:30],100,-420,'Euclidean distance',[1 1]);
axis square;
axis tight;
% text(500,30,sprintf('r=%3.2f, p=%3.4f',rDist, pDist));
text(-380,30,sprintf('r = %3.2f',rDist));
text(-380,25,sprintf('p = %3.2e',pDist));


subplot(3,2,2);
for p=1:size(speed,2)
    [pa(p), L(p)] = ShadedError(tSpeed, squeeze(speed(:,p))', squeeze(speedE(:,p))');
    set(pa(p),'FaceAlpha',0.5);
    hold on
end
setLineColors(L);
set(gca,'visible','off');
hold on;
drawRestrictedLines(0,[0 820]);
getAxesP([-0.4 0.5]*1000,[-0.4:0.2:0.5]*1000,50,-.1,'t (ms)',[0 8]*100,[0:8]*100,150,-420,'Speed (spks/s/s)',[1 1]);
axis square;
axis tight;


subplot(3,2,4);


speedS = squeeze(nanmean(nanmean(r.kinet.speed(:,tSpeed < 0,:),2)));
speedSE = squeeze(nanstd(nanmean(r.kinet.speed(:,tSpeed < 0,:),2)));

[rSpeed,pSpeed] = corr(speedS, squeeze(X)')

errorbar([RTl+RTh]/2, speedS, speedSE,'ko-','markersize',12,'markerfacecolor','k','markeredgecolor','none')
hold on
set(gca,'visible','off');
getAxesP([300 800],[300:200:800],4,29,'RT (ms)',[0.3 0.6]*100,[0.3:0.1:0.6]*100,75,290,'Speed (spks/s/s)',[1 1]);
axis tight;


RTlimA = [RTl+RTh]/2;
axis square;
axis tight;
text(320,35,sprintf('r = %3.2f',rSpeed));
text(320,33,sprintf('p = %3.2e',pSpeed));

subplot(325)
angleS = squeeze(nanmean(r.kinet.spaceAngle))*180/pi;
angleSE = squeeze(nanstd(r.kinet.spaceAngle))*180/pi;
[pa,li] = ShadedError(tVect*1000, angleS, angleSE);
pa.FaceAlpha = 0.5;

drawRestrictedLines(0,[0 180]);
line([tVect(1) tVect(end)]*1000,[90 90],'color','k','linestyle','--');
axis square;
axis tight;
ylim([0 180]);
hold on;
set(gca,'visible','off');
getAxesP([-0.4 0.5]*1000,[-0.4:0.2:0.5]*1000,10,-.1,'t (ms)',[0 180],[0 90 180],100,-420,'Angle',[1 1]);


subplot(326)
angleS = squeeze(nanmean(r.kinet.meanVectorAngle))*180/pi;
angleSE = squeeze(nanstd(r.kinet.meanVectorAngle))*180/pi;
[pa,li] = ShadedError(tVect*1000, angleS, angleSE);
pa.FaceAlpha = 0.5;
  
line([tVect(1) tVect(end)]*1000,[90 90],'color','k','linestyle','--');
drawRestrictedLines(0,[0 180]);
line(get(gca,'xlim'),[0 0],'color','k','linestyle','--');
axis square;
axis tight;
ylim([0 180]);
set(gca,'visible','off');
getAxesP([-0.4 0.5]*1000,[-0.4:0.2:0.5]*1000,10,-.1,'t (ms)',[0 180],[0 90 180],100,-420,'Angle',[1 1]);

cbPos=[0.4 0.9];
cbSize=[0.2 0.015];
fSize=20;
cbLyPos=2.5;

custColorBar(r,cbPos,cbSize,fSize,cbLyPos)

% %plot colorbar
% c=colorbar('Ticks',[0 1],'TickLabels',{'Fast','Slow'},'Location','northoutside',...
%     'FontSize',15);
% c.Label.String = 'RT';
% c.Label.FontName = 'Arial';
% c.Label.FontSize = 20;
% c.Position = [0.4 0.9 0.2 0.015];


end
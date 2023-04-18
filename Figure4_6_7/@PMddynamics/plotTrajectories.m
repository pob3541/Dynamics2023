function plotTrajectories(r, varargin)
% plotTrajectories - plots 3D PCA trajectories for the specified dimensions 
%
%
% Chand, Mar 30th 2022

dimsToShow = r.metaData.dimsToShow;
marker = 's';
step = r.metaData.dt*3;
lW = 2;
m300size = 12;
showPooled= true;
whichCoh = 1;

assignopts(who, varargin);

if showPooled
    tData = r.signalplusnoise.tData;
    cValues = r.metaData.condColors;
    TrajIn = r.signalplusnoise.TrajIn;
    TrajOut = r.signalplusnoise.TrajOut;
else
    tData = r.signalplusnoise.tData;
    cValues = r.metaData.condColors;
    TrajIn = r.perCoh(whichCoh).pcaData.TrajIn;
    TrajOut = r.perCoh(whichCoh).pcaData.TrajOut;
end

f = figure('units','normalized','position',[0.2049 0.1292 0.6026 0.6394],'color',[1 1 1]);

for k=1:11
    
    timePts = tData{k};
    zeroPt = find(timePts >-0.002 & timePts < 0.0,1,'first');
    movePt = find(timePts >.25,1,'first');
    
    S1 = TrajIn{k}(:,dimsToShow(1));
    S2 = TrajIn{k}(:,dimsToShow(2));
    S3 = TrajIn{k}(:,dimsToShow(3));
    
    
    
    X = 1:step:length(S1);
    
    hold on;
    plot3(S1,S2,S3,'color',cValues(k,:),'color', cValues(k,:), 'linewidth',lW);
    E = plot3(S1(X),S2(X),S3(X),'color',cValues(k,:),'MarkerFaceColor', [cValues(k,:)],'MarkerEdgeColor','none','marker',marker,'markersize',6,'linestyle','none');
    
    
    if ~isempty(zeroPt)
        plot3(S1(zeroPt),S2(zeroPt),S3(zeroPt),'color',[0.8 0 0 0.5],'marker','o','markerFaceColor','r','markersize',m300size);
        plot3(S1(movePt),S2(movePt),S3(movePt),'color',cValues(k,:),'marker','d','markerFaceColor',cValues(k,:),'markersize',m300size);
    end
    
    S1 = TrajOut{k}(:,dimsToShow(1));
    S2 = TrajOut{k}(:,dimsToShow(2));
    S3 = TrajOut{k}(:,dimsToShow(3));
    
    X = 1:step:length(S1);
    
    plot3(S1,S2,S3,'color',cValues(k,:),'color', cValues(k,:),  'linewidth',lW,'linestyle','--');
    plot3(S1(X),S2(X),S3(X),'color',cValues(k,:),'MarkerFaceColor', cValues(k,:),'MarkerEdgeColor','none','marker',marker,'markersize',6, 'linestyle','none');
    
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

set(gca,'CameraPosition',r.metaData.camPosition);

ax = gca;
ax.SortMethod = 'ChildOrder';

cbPos=[0.425 0.9];
cbSize=[0.2 0.015];
fSize=20;
cbLyPos=2.5;

custColorBar(r,cbPos,cbSize,fSize,cbLyPos)

end


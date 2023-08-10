function plotBiplot(r)

figure;
biplot(r.signalplusnoise.eigenVectors(:,[1,4]))
axis off
ymin=-.2;
yLims=[-.2,.22];
yTicks=-.2:.05:.22;
xLims=[-.2,.2];
xTicks= -.2:.05:.2;
getAxesP(xLims, xTicks,0.03, -.25, 'PC 1', yLims, yTicks, 0.03, -.25, 'PC 4',[1 1]);
axis tight;
axis square;


figure;
scatter(r.signalplusnoise.eigenVectors(:,1),abs(r.signalplusnoise.eigenVectors(:,4)))
axis off
ymin=0;
yLims=[0,.22];
yTicks=0:.05:0.22;
xLims=[-.2,.2];
xTicks= -.2:.05:.2;
getAxesP(xLims, xTicks,0.03, -0.01, 'PC 1', yLims, yTicks, 0.03, -0.2, 'PC 4',[1 1]);
axis tight;
axis square;

%[r1,p1]=corr(r.signalplusnoise.eigenVectors(:,1),abs(r.signalplusnoise.eigenVectors(:,4)),'type','Pearson');
end
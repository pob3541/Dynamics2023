function plotRegressionToRT(FR, RT, nTrials, varargin)
%
%
%
% Chand, Pierre, Tian: August 2023

numShuffles = 100;
before = 500;
after = 1000;

yLower = 0.0;
yUpper = 0.8;

assignopts(who, varargin);
temp = cat(2,squeeze(FR(:,:,1,:)),squeeze(FR(:,:,2,:)));
FRmatrix = permute(temp,[1,3,2]);

% choose random 50 neurons for regression
load('s.mat');
rng(s);
whichNeurons = randperm(size(FR,1));
binnedFRmatrix = FRmatrix(whichNeurons(1:50),[1:10:end-2],:);

rt = [RT;RT];
decision = [zeros(nTrials,1); ones(nTrials,1)];



for n=1:size(binnedFRmatrix,2)
    [~,~,~,~,st] = regress(RT, cat(2,[squeeze(binnedFRmatrix(:,n,1:300))]',ones(300,1)));
    R2(n) = st(1);
end




shuffledR2 = zeros(size(binnedFRmatrix,2), numShuffles);

parfor ii = 1:numShuffles
    if mod(ii,20)==0
        fprintf('.');
    end
    whichRT = randperm(size(RT,1));
    shuffledRT = RT(whichRT);
    Temp = [];
    for n = 1:size(binnedFRmatrix,2)
        [~,~,~,~,st] = regress(shuffledRT, cat(2,squeeze(binnedFRmatrix(:,n,1:300))',ones(300,1)));
        Temp(n) = st(1);
    end
    shuffledR2(:, ii) = Temp;
end

upper = prctile(shuffledR2,99,2);
lower = prctile(shuffledR2,1,2);

figure(1);
subplot(1,3,2)

t = linspace(-before,after,length(R2));
hold on
plot(t, R2);

plot(t, upper, 'k--');
plot(t,lower, 'k--');


ylimit = [yLower, yUpper];


plot([0,0], ylimit, 'color', [0.5 0.5 0.5], 'linestyle', '--', 'linewidth',5)
title('Regression on RT', 'fontsize', 10)


xpatch = [-before -before 0 0];
ypatch = [yLower yUpper yUpper yLower];
p1 = patch(xpatch, ypatch, 'cyan');
p1.FaceAlpha = 0.2;
p1.EdgeAlpha = 0;


% cosmetic code
hLimits = [-before,after];
hTickLocations = -before:250:after;
hLabOffset = 0.05;
hAxisOffset = yLower-0.01;
hLabel = "Time: ms";

vLimits = ylimit;
vTickLocations = [yLower (yLower + yUpper)/2 yUpper];
vLabOffset = 150;
vAxisOffset = -before-20;
vLabel = "R^{2}";

plotAxis = [1 1];

[hp,vp] = getAxesP(hLimits,...
    hTickLocations,...
    hLabOffset,...
    hAxisOffset,...
    hLabel,...
    vLimits,...
    vTickLocations,...
    vLabOffset,...
    vAxisOffset,...
    vLabel, plotAxis);

set(gcf, 'Color', 'w');
axis off;
axis square;
axis tight;
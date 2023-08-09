function choiceTable = plotChoiceDecoding(FR, RT, nTrials, varargin)
%
%
%
% Chand, Pierre, Tian: August 2023

numShuffles = 100;
before = 500;
after = 1000;

yLower = 0.0;
yUpper = 0.6;

assignopts(who, varargin);
temp = cat(2,squeeze(FR(:,:,1,:)),squeeze(FR(:,:,2,:)));
FRmatrix = permute(temp,[1,3,2]);


whichNeurons = randperm(size(FR,1));
binnedFRmatrix = FRmatrix(whichNeurons(1:30),[1:10:end-2],:);


rt = [RT;RT];
decision = [zeros(nTrials,1); ones(nTrials,1)];


options.rtThreshold = prctile(rt,50);
[accuracy_l] = predictChoice(binnedFRmatrix, rt, decision, options, 'less');
[accuracy_g] = predictChoice(binnedFRmatrix, rt, decision, options, 'greater');

t = linspace(-before, after, length(accuracy_l));

% plot fast trials decoding accuracy
subplot(1,3,3); hold on

yLower = 0.4;
yUpper = 1;

xpatch = [yLower yLower -before -before];
ypatch = [yLower yUpper yUpper yLower];
p1 = patch(xpatch, ypatch, 'cyan');
p1.FaceAlpha = 0.2;
p1.EdgeAlpha = 0;

plot(t, accuracy_l,'linewidth', 3)

xlabel('Time (ms)')
ylabel('Accuracy')
title('Prediction accuracy')

% plot slow trials decoding accuracy
plot(t, accuracy_g,'linewidth', 3)


yline(0.5, 'k--')
xline(0, 'color', [0.5 0.5 0.5], 'linestyle', '--')

xlabel('Time (ms)')
ylabel('Accuracy')
title('Prediction accuracy')


choiceTable = array2table([time' accuracy_l' accuracy_r'],'VariableNames',{'Time','Accuracy Fast','Accuracy Slow'});



% cosmetic code
hLimits = [-before,after];
hTickLocations = -before:250:after;
hLabOffset = 0.05;
hAxisOffset =  yLower - 0.01;
hLabel = "Time: ms";


vLimits = [yLower,yUpper];
vTickLocations = [yLower (yLower + yUpper)/2 yUpper];


vLabOffset = 150;
vAxisOffset = -before-20;
vLabel = "Accuracy";

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


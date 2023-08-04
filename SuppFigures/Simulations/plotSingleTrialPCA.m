function plotSingleTrialPCA(FRc, tNew, nNeurons, Vave)

FRnewSingle = permute(FRc,[1 3 2 4]);

tFinal = tNew > -0.2 & tNew < 0.6;
bigMatrix = [];
for choiceId = 1:2
    fprintf('.');
    for RTid = 1:size(FRnewSingle,3)
        if isempty(bigMatrix)
            bigMatrix = squeeze(FRnewSingle(:,choiceId, RTid, tFinal));
        else
            bigMatrix = cat(2, bigMatrix, squeeze(FRnewSingle(:,choiceId, RTid, tFinal)));
        end
    end
end

[coeff, score, Vsingle] = pca(bigMatrix');

I1 = reshape(score, [sum(tFinal) size(FRnewSingle,3) 2 nNeurons]);



aveVar = cumsum(Vave)./sum(Vave);
trialVar = cumsum(Vsingle)./sum(Vsingle);

figure; hold on
plot(aveVar(1:10), '.-', 'MarkerSize', 20);
plot(trialVar(1:10), '.-', 'markersize', 20);
% (0.9, 'k--')

ylimit = [0 1];
yLower = ylimit(1);
yUpper = ylimit(2);
hLimits = [1,10];
hTickLocations = 1:1:10;
hLabOffset = 0.05;
hAxisOffset = yLower-0.01;
hLabel = "Time: ms";

vLimits = ylimit;
vTickLocations = [yLower (yLower + yUpper)/2 yUpper];
vLabOffset = 0.8;
vAxisOffset = hLimits(1)-0.2;
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
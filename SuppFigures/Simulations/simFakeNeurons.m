time = [0:1:200]/100;
nNeurons = 200;

nTrials = 300;

FRsim = [];
binSize = 0.05;
RT = [200+100*gamrnd(5,0.5,nTrials,1)]./1000;

baseline = 5;

% baseline firing rate of 
nF = 5 + 7*rand(1,nNeurons);
nF2 = 2 + 1*rand(1,nNeurons);
spikes = [];

% checkerboard onset
tStart = 0.6;
% Latency
tLatency = 0.1;
CISmult = 15;

whichType = 'BiasedChoice';

cprintf('cyan',sprintf('-----------------------------------------------\n Simulating %d Neurons from %s, %d trials per neuron \n', nNeurons, whichType, nTrials));

for neuronId = 1:nNeurons
    if rand < 0.2
        baseFR = 3*rand+2;
        baseline = 0;
    else
        baseFR = 0;
        baseline = 5;
    end
    if mod(neuronId, 10) == 0
        cprintf('magenta',sprintf('%d.', neuronId));
    end
    for nChoice = 1:2
        for nTrials = 1:length(RT)
            tLag = tStart + tLatency + 0.2*RT(nTrials);
            
            switch(whichType)
                case 'RT'
                    switch(nChoice)
                        case 1
                            rate = baseline  + ((baseFR)./RT(nTrials) + nF(neuronId)*max((time-tLag)./(RT(nTrials)),0) + max(CISmult*(time-tLag),0));
                        case 2
                            rate = baseline +  (baseFR)./RT(nTrials) - nF2(neuronId)*max((time-tLag)./((RT(nTrials))),0) + max(CISmult*(time-tLag),0);
                            rate(rate < 0) = 0;
                    end
                    
                case 'BiasedChoice'
                    
                        switch(nChoice)
                            case 1
                                rate = baseline + 4*rand + max(CISmult*(time-tLag),0) + nF(neuronId)*max((time-tLag)./RT(nTrials),0);
                            case 2
                                rate = baseline + 2*rand + max(CISmult*(time-tLag),0)- nF2(neuronId)*max((time-tLag)./RT(nTrials),0);
                                rate(rate < 0) = 0;
                        end
                
                  case 'UnbiasedChoice'
                    
                        switch(nChoice)
                            case 1
                                rate = baseline + 2*rand + max(CISmult*(time-tLag),0) + nF(neuronId)*max((time-tLag)./RT(nTrials),0);
                            case 2
                                rate = baseline + 2*rand + max(CISmult*(time-tLag),0)- nF2(neuronId)*max((time-tLag)./RT(nTrials),0);
                                rate(rate < 0) = 0;
                        end

            
            end
            
%             spikes(nTrials).times = generateInhomRenewal(time,rate,'process','gamma','shape',4,'scale',1/4);
            spikes(nTrials).times = generateInhomRenewal(time,rate,'process','poisson');
        end
        
        [~,t,~,RR] = psthcc(spikes, 0.02, 'n',[0 1.6],2,[0:.001:1.6]);
        FRsim(neuronId, :,nChoice, :) = RR;
    end
end


FRsim2 = FRsim;

%%

FR2 = [];
baseline = 5;

for neuronId = 1:50
    OnsetTime = 20*rand-10;
    fprintf('.');
    if rand > 0.5
        mult = [100 50];
    else
        mult = [50 100];
    end
    for nChoice=1:2
        for nTrials = 1:length(RT)
                rate = baseline*ones(1,length(time));
                onsetTime = floor(ceil([tStart + RT(nTrials)])*100-OnsetTime);
                
                rate(onsetTime-20:onsetTime+20) = baseline + mult(nChoice)*normpdf(-20:1:20,0,2);
                rate = rate(1:length(time));
                spikes(nTrials).times = generateInhomRenewal(time,rate,'process','poisson');
        end
        [~,t,~,RR] = psthcc(spikes, 0.03, 'n',[0 2],2,[0:.001:1.6]);
        FR2(neuronId, :,nChoice, :) = RR;
    end
end



%%

figure;
nNeurons = size(FRsim2,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% What is FRtemp?
%%%%%%%%%%%%%%%%%%%%%%%%%%
FRtemp = max(10-FRsim2(1:nNeurons/2,:,:,:),0);
FR = cat(1, FRsim2-5, FRtemp);

FR = cat(1, FR, FR2);

% FR: firing rate of 3 combined simulated neurons
FR = FR(:,:,:,100:end);
tNew = t(100:end) - tStart;


nNeurons = size(FR,1);
FRc = [];
FRc(1:2:nNeurons,:,:,:) = FR(1:2:nNeurons,:,[2 1],:);
FRc(2:2:nNeurons,:,:,:) = FR(2:2:nNeurons,:,[1 2],:);



% plot only 
% plot(squeeze(nanmean(FRsim2(:,:,1,:),2))','-r');
% hold on
% plot(squeeze(nanmean(FRtemp(:,:,1,:),2))','-g');
% plot(squeeze(nanmean(FR2(:,:,1,:),2))','-c');
% 
% plot(squeeze(nanmean(FRsim2(:,:,2,:),2))','-r');
% hold on
% plot(squeeze(nanmean(FRtemp(:,:,2,:),2))','-g');
% plot(squeeze(nanmean(FR2(:,:,2,:),2))','-c');


% plot all units
% plot(tNew, squeeze(nanmean(FR(:,:,1,:),2))','-r');
% hold on;
% plot(tNew, squeeze(nanmean(FR(:,:,2,:),2))','-g');

plot(squeeze(nanmean(FR(:,:,1,:),2))','-r');
hold on;
plot(squeeze(nanmean(FR(:,:,2,:),2))','-g');


% 
% rV = [];
% for n=1:nNeurons
%     rV(n,:) = corr(squeeze(FR(n,:,1,:)),RT,'type','spearman');
% end

%%

% RT at different percentile
RTp = prctile(RT, [0:15:100]);
% lower and upper bound of RT percentile
RTl = RTp(1:end-1)
RTr = RTp(2:end)

FRnew = [];
for cId = 1:length(RTl)
    FRnew(:,:,cId,:) = squeeze(nanmean(FRc(:,RT > RTl(cId) & RT < RTr(cId),:,:),2));
end


%% single trial pca
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

%% RT bin averaged pca


tFinal = tNew > -0.2 & tNew < 0.6;
bigMatrix = [];
for choiceId = 1:2
    for RTid = 1:length(RTl)
        if isempty(bigMatrix)
            bigMatrix = squeeze(FRnew(:,choiceId, RTid, tFinal));
        else
            bigMatrix = cat(2, bigMatrix, squeeze(FRnew(:,choiceId, RTid, tFinal)));
        end
    end
end

bigMatrix = bigMatrix'./repmat(sqrt(prctile(bigMatrix',99)),[size(bigMatrix,2) 1]);

[coeff, score, V] = pca(bigMatrix);

score = bigMatrix*coeff;
figure;
I1 = reshape(score, [sum(tFinal) length(RTl) 2 size(score,2)]);
li1 = plot(tNew(tFinal), squeeze(I1(:,:,1,4)),'-');
hold on
li2 = plot(tNew(tFinal), squeeze(I1(:,:,2,4)),'-');
hold on
setLineColors(li1);
setLineColors(li2);



%% plot single trial vs averaged trial pca variance explained 

aveVar = cumsum(V)./sum(V);

trialVar = cumsum(Vsingle)./sum(Vsingle);

figure; hold on
plot(aveVar(1:10), '.-', 'MarkerSize', 20);
plot(trialVar(1:10), '.-', 'markersize', 20);
yline(0.9, 'k--')

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




% print('-painters','-depsc',['~/Desktop/', 'varSimPMd_RT','.eps'], '-r300');


























%%
I1 = reshape(score, [sum(tFinal) length(RTl) 2 nNeurons]);

figure;
set(gcf,'position',[1000,1000,2000,600])

params = getParams;
params.posterColors;
colV = params.posterColors(ceil(linspace(1,size(params.posterColors,1),length(RTl))),:);

t0 = find(tNew(tFinal) >=0,1,'first');
iX = 1:30:size(I1,1);

orderX = [1:3];

I1(:,:,:,2:3) = -I1(:,:,:,2:3);


subplot(1,3,1)
for nR = 1:length(RTl)
    plot3(squeeze(I1(:,nR,1,orderX(1))), squeeze(I1(:,nR,1,orderX(2))), squeeze(I1(:,nR,1,orderX(3))),'-','color',colV(nR,:));
    hold on
    plot3(squeeze(I1(:,nR,2,orderX(1))), squeeze(I1(:,nR,2,orderX(2))), squeeze(I1(:,nR,2,orderX(3))),'--','color',colV(nR,:));

    
%     plot3(squeeze(I1(iX,nR,1,orderX(1))), squeeze(I1(iX,nR,1,orderX(2))), squeeze(I1(iX,nR,1,orderX(3))),'s','color',colV(nR,:));
%     hold on
%     plot3(squeeze(I1(iX,nR,2,orderX(1))), squeeze(I1(iX,nR,2,orderX(2))), squeeze(I1(iX,nR,2,orderX(3))),'s','color',colV(nR,:));

    hold on
    plot3(squeeze(I1(t0,nR,:,orderX(1))), squeeze(I1(t0,nR,:,orderX(2))),squeeze(I1(t0,nR,:,orderX(3))),'o','markerfacecolor','r','markeredgecolor','none','markersize',12);
    
    hold on
    plot3(squeeze(I1(end,nR,:,orderX(1))), squeeze(I1(end,nR,:,orderX(2))),squeeze(I1(end,nR,:,orderX(3))),'d','markerfacecolor',colV(nR,:),'markeredgecolor','none','markersize',12);
    
end

xlabel('PC_1');
ylabel('PC_2');
zlabel('PC_3');


Tv = ThreeVector(gca);
ax = gca;
ax.SortMethod = 'ChildOrder';

% view([-38 45])
view([8 77])
% print('-painters','-depsc',['~/Desktop/', 'pca_simPMd_CU','.eps'], '-r300');


%% preprocess FR 

% FR: has 1502 time points; checkerboard onset is 500ms. 

% a = squeeze(FR(:,:,1,:));
% b = squeeze(FR(:,:,2,:));
temp = cat(2,squeeze(FR(:,:,1,:)),squeeze(FR(:,:,2,:)));
FRmatrix = permute(temp,[1,3,2]);

whichNeurons = randperm(size(FR,1));
binnedFRmatrix = FRmatrix(whichNeurons(1:30),[1:10:end-2],:);

rt = [RT;RT];
decision = [zeros(nTrials,1); ones(nTrials,1)];


%% 
% binnedFRmatrix = [];
% binWidth = 10;
%   for n = 1:size(FRmatrix,3)
%     yDim = size(FRmatrix, 1);
%     T    = floor(size(d,2) / binWidth);
%     y       = nan(yDim, T);
%     data = squeeze(FRmatrix(:,:,n));
%     for t = 1:T
%       iStart = binWidth * (t-1) + 1;
%       iEnd   = binWidth * t;
%       
%       y(:,t) = sum(data(:, iStart:iEnd), 2);
%       binnedFRmatrix(:,:,n) = y;
%     end
%   end

%% regression RT analysis 
  
for n=1:size(binnedFRmatrix,2)
    
    [b,bi,c,ci,st] = regress(RT, cat(2,[squeeze(binnedFRmatrix(:,n,1:300))]',ones(300,1)));
    R2(n) = st(1);
end


%% regression RT analysis 
% FR_prime = squeeze(FR(:,:,1,1:10:end-2));
% 
% % whichRT = randperm(size(RT,1));
% % RT_prime = RT(whichRT);
% 
% for n=1:size(FR_prime,3)
% 
% [b,bi,c,ci,st] = regress(RT, cat(2,squeeze(FR_prime(1:25,:,n))',ones(300,1)));
% R2_prime(n) = st(1);
% 
% end
% 
% plot(R2_prime)

%% shuffle control 
shuffleTime = 100;
shuffledR2 = zeros(size(binnedFRmatrix,2), shuffleTime);

for ii = 1:shuffleTime
    whichRT = randperm(size(RT,1));
    shuffledRT = RT(whichRT); 
    for n = 1:size(binnedFRmatrix,2)
        [b,bi,c,ci,st] = regress(shuffledRT, cat(2,squeeze(binnedFRmatrix(:,n,1:300))',ones(300,1)));
        shuffledR2(n,ii) = st(1);
    end
end

upper = prctile(shuffledR2,99,2);
lower = prctile(shuffledR2,1,2);
%%
% options.side = 'left';
% [r2] = predictRT(binnedFRmatrix, rt, decision, options);
% 
% plot(r2)

subplot(1,3,2)

before = 500; 
after = 1000;
t = linspace(-500,1000,length(R2));
hold on
plot(t, R2);

plot(t, upper, 'k--');
plot(t,lower, 'k--');

yLower = 0.0;
yUpper = 0.6;

ylimit = [yLower, yUpper]


plot([0,0], ylimit, 'color', [0.5 0.5 0.5], 'linestyle', '--', 'linewidth',5)
title('Regression on RT', 'fontsize', 30)


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

% print('-painters','-depsc',['~/Desktop/', 'r_simPMd','.eps'], '-r300');

%% decoding choice 
options.rtThreshold = prctile(rt,50);
[accuracy_l] = predictChoice(binnedFRmatrix, rt, decision, options, 'less');
[accuracy_g] = predictChoice(binnedFRmatrix, rt, decision, options, 'greater');

t = linspace(-before, after, length(accuracy_l));

%%
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
yline(0.5, 'k--')
xlabel('Time (ms)')
ylabel('Accuracy')
title('Prediction accuracy')

% plot slow trials decoding accuracy
plot(t, accuracy_g,'linewidth', 3)
yline(0.5, 'k--')
xlabel('Time (ms)')
ylabel('Accuracy')
title('Prediction accuracy')



xline(0, 'color', [0.5 0.5 0.5], 'linestyle', '--')


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

%%
% print('-painters','-depsc',['~/Desktop/', 'simPMd_CB','.eps'], '-r300');

NewTraj = [];

figure;

expression = '(x <=tStart).*base + (x >tStart).*(base  + slope1*(x-tStart).^2)';
g = fittype(expression,'coeff',{'tStart','base','slope1'},'indep','x')


slopeV = [];
bV = [];
bVI = [];
FitQuality = [];
Loc = [];
cnt = 1;
nDim = 6;
for n=1:7
    if ismember(n,[1 4 7])
        subplot(3,2,2*cnt-1);
        plotData = true;
        cnt = cnt + 1;
    else
        plotData = false;
    end
    li = [];
    for m=1:11
        
        Loc(n,m,:) = [nanmean(N.perCoh(n).pcaData.TrajIn{m}(100:300,1:nDim)) nanmean(N.perCoh(n).pcaData.TrajOut{m}(100:300,1:nDim))];
        dist{m} = sqrt(sum([N.perCoh(n).pcaData.TrajIn{m}(:,1:nDim) - N.perCoh(n).pcaData.TrajOut{m}(:,1:nDim)].^2,2));
        hold on;
        Y = dist{m};
        
        tV = N.perCoh(n).pcaData.tData{m};
        iX = find(tV > 0.125 & tV < 0.375);
        if plotData
            li(m) = plot(tV*1000, dist{m},'-');
        end
        slopeV(n,m) = nanmean(Y(iX(1:10:end)));
        % slopeV(n,m) = Y(iX(end)) - Y(iX(1));
        
        
        tS = N.perCoh(n).pcaData.tData{m}*1000;
        tVals = (tS > -200 & tS < 400);
        [R,goodness] = fit(tS(tVals)',squeeze(double(Y(tVals))),g,'StartPoint',[100 3 0.0001]);
        FitQuality(n,m) = goodness.rsquare;
        bV(n,m,:) = coeffvalues(R);
        bVI(n,m,:,:) = confint(R);

        
    end
    if plotData
        setLineColors(li);
        
        yLims = [0 100]
        xLims = [-400 500];
        xTicks = [-400 200 400];
        cTextLabels = getTextLabel(0,{'Cue'},{'b'});
        yTicks = [yLims(1) yLims(2)];
        getAxesP(xLims, xTicks, 12.5, yLims(1), 'Time (ms)', yLims, yTicks, 100, xLims(1)-20, 'High D Distance',[1 1],cTextLabels);
        drawRestrictedLines(0,yLims,'lineStyle','--');
        axis tight; axis square;
        set(gca,'visible','off');

        
    end
    
end

%%
figure;
X = [];
Y = [];
cnt = 1;
RTv = mean(N.metaData.RTlims);
id = [];
RTbin = [];
for n=1:7
    for m=[1:11]
        X(cnt,1:size(Loc,3)) = squeeze(Loc(n,m,:));
        id(cnt) = n;
        RTbin(cnt) = RTv(m);
         Y(cnt) = slopeV(n,m);
%         Y(cnt) = bV(n,m,3);
        Ylatency(cnt) = bV(n,m,1);
        Y2(cnt) = bV(n,m,3);
        cnt = cnt + 1;
    end
end
X2 = X;
X2(:,end+1) = 1;

%%
figure;
X(:,end+1) = 1;
X = X-repmat(nanmean(X),[size(X,1) 1]);
[P,F, V1] = pca(X(:,1:nDim*2));
X1 = [];
X1(:,1) = F(:,1);
X1(:,2) = id;
X1(:,3) = 1;
[bRegress,bi,c,ci,st] = regress(Y',X1);
subplot(3,2,[4 6]);
li = [];
p = getParams;
ColVals = repmat([0 0.5 0.55 0.6 0.65 0.72 0.84]',1,3);
for b=[1 3 5 7]
    a1 = F(id==b,1);
    a2 = Y(id==b);
    plot(F(id==b,1), Y(id==b),'-','color',ColVals(b,:),'linewidth',2);
    hold on
    for k=1:length(a1)
        plot(a1(k),a2(k),'o','markerfacecolor',p.posterColors(k,:), 'markersize',12,'markeredgecolor','none');
    end
    hold on
end
set(gca,'visible','off');
setLineColors(li);
hold on;
% getAxesP([-20 20],[-20 0 20],6,-2,'Initial Condition',[0 60],[0 60],2,-20.5,'Slope',[1 1]);
axis square;
axis tight;


subplot(3,2,[3 5]);
li = [];
for b=[1 3 5 7]
     a1 = F(id==b,1);
    a2 = Ylatency(id==b);
    li(b) = plot(F(id==b,1), Ylatency(id==b),'-','color',ColVals(b,:),'linewidth',2);
      hold on
    for k=1:length(a1)
        plot(a1(k),a2(k),'o','markerfacecolor',p.posterColors(k,:), 'markersize',12,'markeredgecolor','none');
    end
    hold on
end
set(gca,'visible','off');
% setLineColors(li);
hold on;
getAxesP([-20 20],[-20 0 20],20,-2,'Initial Condition',[0 250],[0 125 250],5,-20.5,'Latency (ms)',[1 1]);
axis square;
axis tight;


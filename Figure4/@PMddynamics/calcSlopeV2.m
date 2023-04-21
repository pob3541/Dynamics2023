function 

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
    for m=1:length(N.perCoh(n).pcaData.TrajIn)
        
        Loc(n,m,:) = [nanmean(N.perCoh(n).pcaData.TrajIn{m}(100:400,1:nDim)) nanmean(N.perCoh(n).pcaData.TrajOut{m}(100:400,1:nDim))];
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
        tVals = (tS > -100 & tS < 375);
        [R,goodness] = fit(tS(tVals)',squeeze(double(Y(tVals))),g,'StartPoint',[100 3 0.0001]);
        if plotData & n==1
            hold on
            %             plot(R,'r-');
        end
        
        FitQuality(n,m) = goodness.rsquare;
        bV(n,m,:) = coeffvalues(R);
        bVI(n,m,:,:) = confint(R);
        
        
        %         L = diff(Y(tS > -100 & tS < 400));
        %         allSeq = FindMeAllSequencesOfStep(find(L > 0.1*prctile(L,99))', 1, 50);
        %         bV(n,m,1) =  allSeq{1}(1);
        %
        %         Ycurr = Y(tS > -100 & tS < 400);
        %         bV(n,m,3) = Ycurr(bV(n,m,1)+50)-Ycurr(bV(n,m,1));
        %
        
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
idV = [];
Ylatency = [];
Yslope = [];
cnt = 1;
RTv = mean(N.metaData.RTlims);
id = [];
RTbin = [];
cohValues = [11 45 67 78 90 101 108]
cohValues = abs(cohValues - (225-cohValues))./225
for n=1:size(Loc,1)
    for m=[1:size(Loc,2)]
        X(cnt,1:size(Loc,3)) = squeeze(Loc(n,m,:));
        idV(cnt) = cohValues(n);
        id(cnt) = n;
        RTbin(cnt) = RTv(m);
        Yave(cnt) = slopeV(n,m);
        Yslope(cnt) = bV(n,m,3);
        Ylatency(cnt) = bV(n,m,1);
        Y2(cnt) = bV(n,m,3);
        cnt = cnt + 1;
    end
end
X2 = X;
X2(:,end+1) = 1;

%%
figure;
subplot(311)
X(:,end+1) = 1;
X = X-repmat(nanmean(X),[size(X,1) 1]);
[P,F, V1] = pca(X(:,1:nDim*2));
X1 = [];
X1(:,1) = F(:,1);
X1(:,2) = idV;
X1(:,3) = F(:,1).*idV';
X1(:,4) = 1;
Y = Yave;
[bRegress,bi,c,ci,st] = regress(Y',X1);
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
% setLineColors(li);
hold on;
getAxesP([-20 20],[-20 0 20],6,-2,'Initial Condition',[0 60],[0 60],2,-22,'Average',[1 1]);
axis square;
axis tight;

[r1,p1] = partialcorr(Yave',X1(:,1),X1(:,2))
text([-10],50,sprintf('Corr:%3.2f( p = %3.2f)',r1,p1));


[r2,p2] = partialcorr(Yave',X1(:,2),X1(:,1))
text([-10],10,sprintf('Corr:%3.2f( p = %3.2f)',r2,p2));

subplot(3,1,2);
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
getAxesP([-20 20],[-20 0 20],20,-2,'Initial Condition',[0 250],[0 125 250],5,-22,'Latency (ms)',[1 1]);
axis square;
axis tight;

[r1,p1] = partialcorr(Ylatency',X1(:,1),X1(:,2))
text([-10],250,sprintf('Corr:%3.2f( p = %3.2f)',r1,p1));


[r2,p2] = partialcorr(Ylatency',X1(:,2),X1(:,1))
text([-10],10,sprintf('Corr:%3.2f( p = %3.2f)',r2,p2));



subplot(3,1,3);
li = [];
for b=[1 3 5 7]
    a1 = F(id==b,1);
    a2 = Yslope(id==b);
    li(b) = plot(F(id==b,1), Yslope(id==b),'-','color',ColVals(b,:),'linewidth',2);
    hold on
    for k=1:length(a1)
        plot(a1(k),a2(k),'o','markerfacecolor',p.posterColors(k,:), 'markersize',12,'markeredgecolor','none');
    end
    hold on
end
set(gca,'visible','off');
% setLineColors(li);
hold on;
getAxesP([-20 20],[-20 0 20],0.0005,-0.0005,'Initial Condition',[0 0.003],[0:0.001:0.003],5,-22,'Slope  (ms)',[1 1]);
axis square;
axis tight;


[r1,p1] = partialcorr(Yslope',X1(:,1),X1(:,2))
text([-10],.003,sprintf('Corr:%3.2f( p = %3.2f)',r1,p1));


[r2,p2] = partialcorr(Yslope',X1(:,2),X1(:,1))
text([-10],.0005,sprintf('Corr:%3.2f( p = %3.2f)',r2,p2));

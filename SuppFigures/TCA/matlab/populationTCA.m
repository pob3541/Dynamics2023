%%

monkeys = {'o','t'};
r = [];
cnt = 1;
st = [];
st1 = [];
trainError = [];
testError = [];

whichT = 1:50:1200;
verbose = false;


whichCV = 'hard';

if whichCV == 'hard'
    cprintf('magenta','Using Hard Cross Validation');
else
    cprintf('yellow','Using soft Cross Validation');
end
for m = 1:2


    monkey = monkeys{m};

    switch(monkey)

        case 'o'
            %    olafV = [13 24:26 30 33 36 38 40 41 43 44 45 46 47 48 49 50 52 53 54 55 56 61 62 63 70];

            olafV = [13 24:26 30 33 36 38 41 43 45 46 47 49 52 53 54 55 56 61 70];

            whichSess = olafV;
            [Sessions, remoteDir, remoteScratch] = validOlafSessions('PMd');
        case 't'

            whichSess = setdiff(52:75, 57);
            %             whichSess = 58:75
            [Sessions, remoteDir, remoteScratch] = validSessions('PMd');
            % whichSess = 52
    end


    for sId = whichSess
        fprintf('\n %d',sId);

        [forTCA,nL, nR] = getTCAdata(sId, 'monkey',monkey,'reMake',0);
        forRRR = cat(3, forTCA.dataStruct.RawData.Left, forTCA.dataStruct.RawData.Right);
        RTs = [forTCA.dataStruct.Info.Left.goodRTs'; forTCA.dataStruct.Info.Right.goodRTs'];
        nSquares = [forTCA.dataStruct.Info.Left.nSquares'; forTCA.dataStruct.Info.Right.nSquares'];
        nSquares = abs([nSquares-(225-nSquares)]./225);
        choiceV = [ones(1, forTCA.nL) 2*ones(1,forTCA.nR)];
        tAxis = forTCA.dataStruct.RawData.timeAxis;

        tValues = tAxis < 0;
        Y = forRRR(whichT,:,:);
        Y = permute(Y,[2 1 3]);

        Yt = tensor(Y);
        Yr = ones(size(Yt));

        switch(whichCV)
            case 'hard'
                for n=1:size(Yr,3)
                    whichNeuron = [randi(size(Yr,1),1,1)];
                    if rand < .25
                        Yr(whichNeuron,:,n) = 0;
                    end
                end
            case 'soft'
                Yr = rand(size(Yt));
                Yr(Yr > 0.2) = 1;
                Yr(Yr <=0.2) = 0;
        end


        rTemp = [];
        dId = 1;
        for d = [1:4]

            [model, U0,out] = cp_wopt(Yt, Yr, d,'verbosity',0);

            if sId == 52 & monkey == 't' & d == 4
                %  [model, U0, out] = cp_als(Yt, 4);
                modelToUse = model;
                viz_ktensor(model, ...
                    'Plottype', {'bar', 'line', 'scatter'}, ...
                    'Modetitles', {'neurons', 'time', 'trials'})
            end

            fullData = full(model);
            fullData = fullData.data(find(Yr));
            Ydata = Yt.data(find(Yr));

            trainError(cnt, dId) = 1 - norm(fullData - Ydata,'fro').^2/norm(Ydata - mean(Ydata),'fro').^2;
            RCs(cnt,dId, 1) = norm(fullData - Ydata, 'fro')./norm(Ydata,'fro');

            fullData = full(model);
            fullData = fullData.data(find(~Yr));
            Ydata = Yt.data(find(~Yr));

            testError(cnt, dId) = 1 - norm(fullData - Ydata,'fro').^2/norm(Ydata - mean(Ydata),'fro').^2;
            RCs(cnt,dId, 2) = norm(fullData - Ydata, 'fro')./norm(Ydata,'fro');


            Yproj = [];
            X1 = model.u;
            ix = [1:d];
            for dX = 1:d
                Yproj(dX,:,:) = X1{3}(:,ix(dX)).*X1{2}(:,ix(dX))';
            end
            tAll = tAxis(whichT);
            [rTemp,p] = corr(model.u{3}, RTs, 'type','spearman');
            [b,bi,c,ci,st(cnt,dId,:)] = regress(RTs, [nanmean(Yproj(:,:,tAll < 0),3)' nSquares ones(size(RTs,1),1)]);

            [b,bi,c,ci,stR(cnt,dId,:)] = regress(RTs(randperm(length(RTs))), [nanmean(Yproj(:,:,tAll < 0),3)' nSquares ones(size(RTs,1),1)]);

            [b,bi,c,ci,st1(cnt,dId,:)] = regress(RTs, [nSquares ones(size(RTs,1),1)]);


            sessStats(cnt,:) = [sId size(Yt)];
            dId = dId + 1;


        end
        if verbose
            cprintf('red',sprintf('\n Train Error: %3.3f, \n test Error: %3.3f, \n R2: %3.3f', trainError(cnt,:), testError(cnt,:), st(cnt,:)));
        end
        cnt = cnt + 1;


    end
end

%%
tAll = tAxis(whichT);
classifydata = nanmean(Yproj(:,:,tAll < 0),3)';
groups = choiceV';


for i=1:10
    allData = randperm(length(groups));
    trainIdx = allData(1:ceil(0.7*length(allData)));
    testIdx = setdiff(allData, trainIdx);

    classPred = classify(classifydata(testIdx,:), classifydata(trainIdx,:), groups(trainIdx,:));
    actual(i) = nanmean(classPred == groups(testIdx));
end
nanmean(actual(i))

groups = choiceV(randperm(length(groups)))';
for nS=1:100
    groups = choiceV(randperm(length(groups)))';
    classPred = classify(classifydata(testIdx,:), classifydata(trainIdx,:), groups(trainIdx,:));
    acc(nS) = nanmean(classPred == groups(testIdx));
end

%%
oldTestError = testError;

%%
testError(testError < 0) = NaN
figure;
subplot(221);
hold on
trainColor = [.1 0.4 0.5];
testColor = [0.8 0.3 0];
errorbar(1:4, nanmean(trainError*100), nanstd(trainError*100)./sqrt(sum(~isnan(trainError))),'o-','color',trainColor,'markerfacecolor',trainColor,'markeredgecolor','none','markersize',12);
errorbar(1:4, nanmean(testError*100), nanstd(testError*100)./sqrt(sum(~isnan(testError))),'o-','color',testColor,'markerfacecolor',testColor,'markeredgecolor','none','markersize',12);
set(gca,'visible','off');
getAxesP([1 4],[1:4],'Rank',20,20,[0.2 .5]*100,[0.2:0.10:0.5]*100,'Variance (%)',0.65,0.85,[1 1]);
axis square;
axis tight;


subplot(222);
hold on
errorbar(1:4, nanmean(st(:,:,1)*100), nanstd(st(:,:,1)*100)./sqrt(sum(~isnan(testError))),'o-','color',testColor,'markerfacecolor',testColor,'markeredgecolor','none','markersize',12);
set(gca,'visible','off');
getAxesP([1 4],[1:4],'Rank',5,5,[.05 0.4]*100,[0.05:0.10:0.4]*100,'Variance (%)',0.65,0.85,[1 1]);
axis square;
axis tight;
yline(nanmean(st1(:,1,1))*100)



%%

figure;
model = modelToUse;
fullData = full(model);
Xticks = {[1:5:size(fullData,1)],[tAxis(whichT)],[1:100:size(fullData,3)]};
Info = viz_ktensor(model, ...
    'Plottype', {'bar', 'line', 'scatter'}, ...
    'Modetitles', {'neurons', 'time', 'trials'},'PlotColors',{[0.6 0.6 0.6],[0 0 0],[0.8 0.8 0.8]});


set(Info.FactorAxes(2,4),'Xtick',[1:4:length(whichT)],'XTickLabel',tAxis(whichT(1:4:length(whichT))),'box','off');
ax = Info.FactorAxes(2,4);
axes(ax);
drawLines(13);



%%
figure

sId = 52;
[forTCA,nL, nR] = getGPFAdata(sId, 'monkey',monkey,'reMake',0);
forRRR = cat(3, forTCA.dataStruct.RawData.Left, forTCA.dataStruct.RawData.Right);
RTs = [forTCA.dataStruct.Info.Left.goodRTs'; forTCA.dataStruct.Info.Right.goodRTs'];
nSquares = [forTCA.dataStruct.Info.Left.nSquares'; forTCA.dataStruct.Info.Right.nSquares'];
nSquares = abs([nSquares-(225-nSquares)]./225);
choiceV = [ones(1, forTCA.nL) 2*ones(1,forTCA.nR)];
tAxis = forTCA.dataStruct.RawData.timeAxis;

X1 = modelToUse.u;
Vl = choiceV' == 1 & RTs < 350;
Vl = find(Vl);
Vl = Vl(1:1:min(length(Vl),50));
Vr = choiceV' == 1 & RTs > 600;
Vr = find(Vr);
Vr = Vr(1:1:min(length(Vr),50));

ix = [2 :4];
Y1 = X1{3}(:,ix(1)).*X1{2}(:,ix(1))';
Y2 = X1{3}(:,ix(2)).*X1{2}(:,ix(2))';
Y3 = X1{3}(:,ix(3)).*X1{2}(:,ix(3))';



tId = 1:size(Y1,2);
hold on
tAll = tAxis(whichT);
for i=1:length(Vl)
    currT = find(tAll*1000 >= RTs(Vl(i)),1,'first');
    if isempty(currT) | currT > length(tAll)
        currT = length(tAll);
    end
    plot3(Y1(Vl(i),currT)', Y2(Vl(i),currT)', Y3(Vl(i),currT)', 'bd','markerfacecolor','b','markeredgecolor','none','markersize',12);
    hold on;
    currT = currT + 4;
    plot3(Y1(Vl(i),:)', Y2(Vl(i),:)', Y3(Vl(i),:)', 'b-');

end


tAll = tAxis(whichT);
for i=1:length(Vr)
    currT = find(tAll*1000 >= RTs(Vr(i)),1,'first');
    if isempty(currT) | currT > length(tAll)
        currT = length(tAll);
        hold on;
        plot3(Y1(Vr(i),1:currT)', Y2(Vr(i),1:currT)', Y3(Vr(i),1:currT)', 'm-');
    else
        plot3(Y1(Vr(i),1:currT)', Y2(Vr(i),1:currT)', Y3(Vr(i),1:currT)', 'm-');
        plot3(Y1(Vr(i),currT)', Y2(Vr(i),currT)', Y3(Vr(i),currT)', 'mo','markerfacecolor','m','markeredgecolor','none','markersize',12);
    end


end
tAll = find(tAll >= 0,1,'first');
plot3(Y1(Vl,tAll)', Y2(Vl,tAll)', Y3(Vl,tAll)', 'bo','markerfacecolor','b','markeredgecolor','none','markersize',12);
hold on
plot3(Y1(Vr,tAll)', Y2(Vr,tAll)', Y3(Vr,tAll)','mo','markerfacecolor','m','markeredgecolor','none','markersize',12);

xlabel('S_2');
ylabel('S_3');
zlabel('S_4');

ThreeVector(gca);

ax = gca;
set(ax,'CameraPosition', [0.0652 0.0435 0.0367]);
set(ax,'CameraTarget', [0.0063 0.0040 0.0100]);



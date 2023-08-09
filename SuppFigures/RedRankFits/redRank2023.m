
%
%
%% Chandrasekaran, Chandramouli (CC)
% March 27th 2023
% Revisions of the PMd Dynamics Paper
%
% Calculates Reduced Rank Regression between future timepoints and the
% current time point.
%
% Also shows that the angle between the subspaces identified at each
% timepoint are close to one another for much of the time period and thus a
% RRR analog of the results from the Kinet Analyses that we showed
% previously.


rng('default');
scnt = 1;
AllRsquare = [];
AllRsquare_s = [];
SIds = [];
subCCmean = logical(0);

monkeys = {'o','t'};

AllBetaCorr = {};
AllBetaShuffCorr = {};

mult = 0.7;
alignAngles = [];
rankV = [];
warning('off','MATLAB:eigs:AmbiguousSyntax');

for m = 1:2
    
    
    monkey = monkeys{m};
    
    switch(monkey)
        
        case 'o'
            %    olafV = [13 24:26 30 33 36 38 40 41 43 44 45 46 47 48 49 50 52 53 54 55 56 61 62 63 70];
            
            olafV = [13 24:26 30 33 36 38 41 43 45 46 47 49 52 53 54 55 56 61 70];
            
            whichSess = olafV;
            [Sessions, remoteDir, remoteScratch] = validOlafSessions('PMd');
        case 't'
            
            whichSess = setdiff(52:75, [57 65]);
            [Sessions, remoteDir, remoteScratch] = validSessions('PMd');
    end
    
    
    for sId = whichSess
        fprintf('\n %d',sId);
        
        [forTCA,nL, nR] = getTCAdata(sId, 'monkey',monkey,'reMake',0);
        
        forRRR = cat(3, forTCA.dataStruct.RawData.Left, forTCA.dataStruct.RawData.Right);
        choiceV = [ones(1, forTCA.nL) 2*ones(1,forTCA.nR)];
        nSquares = [forTCA.dataStruct.Info.Left.nSquares'; forTCA.dataStruct.Info.Right.nSquares'];
        nSquares = abs([nSquares-(225-nSquares)]./225);
        RTs = [forTCA.dataStruct.Info.Left.goodRTs'; forTCA.dataStruct.Info.Right.goodRTs'];
        forRRR = permute(forRRR, [3 2 1]);
        tAxis = forTCA.dataStruct.RawData.timeAxis;
        if subCCmean
            forRRR = forRRR - repmat(nanmean(forRRR),[size(forRRR,1) 1 1]);
        end
        
        
        try
            mse = [];
            mse_s = [];
            mse_cnt = [];
            mse_t = [];
            ErrV = [];
            cnt = 1;
            rsquare = [];
            rsquare_s = [];
            
            betaA = [];
            betaS = [];
            
            whichTimePoint = 100;
            timeValues = setdiff([200:100:1600],[whichTimePoint]);
            
            
            for tid = timeValues
                fprintf('%d.',tid);
                [betaA(cnt,:,:), mse(cnt), rankV(scnt, cnt), mse_t(cnt,:), rsquare(cnt,:), yPred] = rrr([forRRR(:,:,whichTimePoint) choiceV' nSquares], [forRRR(:,:,tid) ],'rank',...
                    [ceil(mult*size(forRRR,1)/10)*10 5]);
                
           

                X1d = squeeze((betaA(1,:,2:end-2)));
                X2d = squeeze((betaA(cnt,:,2:end-2)));
                
                alignAngles(scnt, cnt,1) = subspace(X1d, X2d);
                
                D = forRRR(:,:,tid);
                D = D(:);
                ErrV(cnt) = nanmean([D - nanmean(D)].^2);
                
                hold on
                
                Temp = forRRR;
                %                 Temp = Temp(randperm(size(forRRR,1)),randperm(size(forRRR,2)),randperm(size(forRRR,3)));
                Temp = Temp(randperm(size(forRRR,1)),:,:);
                Temp = Temp(randperm(size(forRRR,1)),:,:);
                %             Temp = Temp(:,randperm(size(forRRR,2)),:);
                %             Temp = repmat(nanmean(Temp),[size(forRRR,1) 1 1]);
                cV = choiceV(randperm(size(forRRR,1)));
                
                
                for nS = 1:1
                    [betaS(cnt,:,:), mse_s(nS, cnt), t, mse_cnt(cnt,:), rsquare_s(cnt,:)] = rrr([Temp(:,:,whichTimePoint) choiceV' nSquares], [forRRR(:,:,tid) ],'rank',...
                        [ceil(mult*size(forRRR,1)/10)*10 5]);
                end
                
                X1d = squeeze((betaS(1,:,2:end-2)));
                X2d = squeeze((betaS(cnt,:,2:end-2)));
                
                alignAngles(scnt, cnt,2) = subspace(X1d, X2d);
                cnt = cnt + 1;
            end
            
            %             figure(1);
            %             plot(tAxis(timeValues), max(rsquare,[],2));
            %             hold on;
            %             plot(tAxis(timeValues), max(rsquare_s,[],2));
            %             hold on;
            %             reflinecc(0);
            %             drawRestrictedLines(0,[-0.05 0.3]);
            %             drawnow;
            rawData = [ones(size(forRRR,1),1) forRRR(:,:,whichTimePoint) choiceV' nSquares];
            [beta1,~,~,~,st1] = rrr([rawData(:,2:end)], RTs, 'rank',[ceil(mult*size(forRRR,1)/10)*10 5])
            
            
            [AllBetaCorr{scnt}, pV{scnt}] = corr(squeeze(nanmean(betaA(1:3,:,2:end-2),1))', squeeze(beta1(2:end-2))');
            [AllBetaShuffCorr{scnt}, pVs{scnt}] = corr(squeeze(nanmean(betaS(1:3,:,2:end-2),1))', squeeze(beta1(2:end-2))');
            
            % keyboard
            
            X11 = squeeze(beta1(2:end-2))';
            X21 = squeeze(nanmean(betaA(1:3,:,2:end-2)))';
            X2s = squeeze(nanmean(betaS(1:3,:,2:end-2)))';
            
            AllAngles(scnt,:) = [subspace(X11, X21) subspace(X11, X2s)]
            
            AllRsquare(scnt,:) = max(rsquare,[],2);
            AllRsquare_s(scnt,:) = max(rsquare_s,[],2);
            SIds(scnt,:) = [sId size(forRRR,2) size(forRRR,1)];
            
            scnt = scnt + 1;
        catch
            sId
            
        end
        
        %     AllRsquare(abs(AllRsquare) > 2) = NaN;
        %     AllRsquare(AllRsquare < -0.2) = NaN;
        %     AllRsquare_s(abs(AllRsquare_s) > 2) = NaN;
        nanmean(abs(cell2mat(AllBetaCorr')))
        nanmean(abs(cell2mat(AllBetaShuffCorr')))
        
        figure(2);
        cla;
        plot(nanmean(AllRsquare));
        hold on
        plot(nanmean(AllRsquare_s));
        %         ylim([-.05 0.05]);
        drawnow;
        
        figure(3);
        cla
        plot(squeeze(nanmean(alignAngles)));
        
        
        
    end
end


%% Figure plotting

subplot(221);
Sv = squeeze(AllRsquare(21,:))*100;
plot(tAxis(timeValues)*1000, Sv,'mo-')
hold on;
Svs = squeeze(AllRsquare_s(21,:))*100;
plot(tAxis(timeValues)*1000, Svs,'ko-')
hold on;


drawRestrictedLines(0,[10 50]);
drawRestrictedLines(tAxis(whichTimePoint)*1000,[10 50]);

set(gca,'visible','off');
getAxesP([-600 1000],[-600:200:1000],'Time (ms)',9,5,[10 50],[10:10:50],'R^2 (%)',-625,10);
axis square;
axis tight


rrrData.single = array2table([tAxis(timeValues)'*1000 Sv' Svs'],'VariableNames',{'Time','Real','Shuffled'});



subplot(222);
ix = find(~(sum(AllRsquare < 0 | AllRsquare > 1,2)));
Sv = squeeze(nanmean(AllRsquare(ix,:)))*100;
Sve = squeeze(nanstd(AllRsquare(ix,:)))*100./sqrt(size(AllRsquare,1));
% Sve = nanstd(bootstrp(1000,@nanmean,AllRsquare(ix,:)));

ShadedError(tAxis(timeValues)*1000, squeeze(Sv),Sve);

% plot(tAxis(timeValues), prctile(AllRsquare,[5 95]));
hold on
ix = find(~(sum(AllRsquare_s < 0 | AllRsquare_s > 1,2)));
plot(tAxis(timeValues)*1000, squeeze(nanmean(AllRsquare_s(ix,:)))*100,'ko-')

drawRestrictedLines(0,[20 40]);
drawRestrictedLines(tAxis(whichTimePoint)*1000,[20 40]);
% drawLines(tAxis(whichTimePoint));
set(gca,'visible','off');
getAxesP([-600 1000],[-600:200:1000],'Time (ms)',19,5,[20 40],[20:5:40],'R^2 (%)',-625,10);
axis square;
axis tight

text(-400,22,sprintf('%d sessions',size(AllRsquare(ix,:),1)));

rrrData.average = array2table([tAxis(timeValues)'*1000 Sv' Sve'],'VariableNames',{'Time','Real','Shuffled'});



subplot(223)

tNew = tAxis(timeValues)*1000;

alignAngle = squeeze(nanmean(alignAngles(:,2:end,:)*180/pi));
alignAngleE = squeeze(nanstd(alignAngles(:,2:end,:)*180/pi)/sqrt(size(alignAngles,1)));

errorbar(tNew(2:end), alignAngle(:,1), alignAngleE(:,1));
hold on

errorbar(tNew(2:end), alignAngle(:,2), alignAngleE(:,2));
hold on

drawRestrictedLines(0,[10 90]);
l = refline([0 90]);
l.Parent.XLim = [-600 1000];
l.LineStyle = '--';
% drawLines(tAxis(whichTimePoint));
set(gca,'visible','off');
getAxesP([-600 1000],[-600:200:1000],'Time (ms)',10,5,[10 95],[10:20:90],'R^2 (%)',-625,10);
axis square;
axis tight;

rrrData.angle = array2table([tNew(2:end)' alignAngle alignAngleE],'VariableNames',{'Time','Angle','AngleS','Error','ErrorS'});



subplot(224);

Xangle = rad2deg(AllAngles);

plot(Xangle(:,1), Xangle(:,2),'o','markerfacecolor','k',...
    'markeredgecolor','none','markersize',8,'linestyle','none');
set(gca,'visible','off');
xlim([0 90]);
ylim([0 90]);
hold on;
r1 = refline([1 0])
r1.LineStyle = '--';
r1.Color = [0 0 0];
getAxesP([0 90],[0:20:90],'Time (ms)',-7,5,[0 90],[0:20:90],'R^2 (%)',-7,10);
axis tight;
axis square;
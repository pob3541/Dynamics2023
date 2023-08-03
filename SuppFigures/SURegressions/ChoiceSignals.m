load('ChoicePerRTbin_hardCoh.mat');
subplot(221)
tV = [-600:1200];
idx = 1:10:length(tV);

SE = nanstd(bootstrp(1000,@nanmean,allFastHardCoh(:,idx,1)));

[pa,li] = ShadedError(tV(idx), squeeze(nanmean(allFastHardCoh(:,idx,1)))*100,2*SE*100);
set(pa,'facecolor',[0 1 0.7],'FaceAlpha',0.5);
hold on

SE = nanstd(bootstrp(1000,@nanmean,allSlowHardCoh(:,idx,1)));
[pa, li] = ShadedError(tV(idx), squeeze(nanmean(allSlowHardCoh(:,idx,1)))*100,2*SE*100);
drawRestrictedLines(0,[0 50]);
set(pa,'facecolor',[0 .3 0.9],'FaceAlpha',0.5);
hold on




load('RTandChoice_hardCoh.mat')
SE = nanstd(bootstrp(1000,@nanmean,justHardRTsigmap(:,idx,1)));
[pa, li] = ShadedError(tV(idx), squeeze(nanmean(justHardRTsigmap(:,idx,1)))*100,2*SE*100);
set(li,'color',[0.92 0.7 0.1]);
hold on;


set(gca,'visible','off');
getAxesP([-600 1200],[-600 -300 300:300:1200],0.1*50,-1,'Time (ms)',[0 50],[0:10:50],0.1*1800,-625,'Significant (%)',[1 1]);
axis tight;
axis square;
xlim([-600 1200]);
reflinecc([0 1]);

text([-600],50,'Hard Coherences, 2 RT bins');



%%
subplot(2,2,2);
load('RTandChoice_allCoh.mat');
SE = nanstd(bootstrp(1000,@nanmean,allRTsigmap(:,idx,1)));
[pa, li] = ShadedError(tV(idx), squeeze(nanmean(allRTsigmap(:,idx,1)))*100,2*SE*100);
set(li,'color',[0.92 0.7 0.1]);
hold on;


SE = nanstd(bootstrp(1000,@nanmean,allRTsigmap(:,idx,2)));
[pa,li] = ShadedError(tV(idx), squeeze(nanmean(allRTsigmap(:,idx,2)))*100,2*SE*100);
set(pa,'facecolor',[0 .3 0.9],'FaceAlpha',0.5);
hold on;
drawRestrictedLines(0,[0 100]);


set(gca,'visible','off');
getAxesP([-600 1200],[-600 -300 300:300:1200],0.1*100,-1,'Time (ms)',[0 100],[0:20:100],0.1*1800,-625,'Significant (%)',[1 1]);
axis tight;
axis square;
xlim([-600 1200]);
reflinecc([0 1]);

text([-600],100,'All Coherences, RT and Choice');

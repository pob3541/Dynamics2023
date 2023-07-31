% rawFR = permute(AllSess.outcomePCA_trunc,[2 3 4 1]);
% for nConds=1:4
%     for nC = 1:2
%         projData(:,nConds,nC,:) = r.project.projSpace(:,1:6)'*squeeze(rawFR(:,nConds, nC,:));
%         Temp = squeeze(projData(:,nConds, nC,:));
%         projData(:,nConds,nC,:) = Temp - nanmean(Temp);
%     end
% end
% % Sigma = sqrt(prctile(abs(projData),99)+2);
% % projData = projData./repmat(Sigma, size(projData,1),1);

%% have to preprocess raw FRs


Data=permute(AllSess.outcomePCA_trunc,[2 3 4 1]);
Mu = nanmean(Data);
Data = [Data - repmat(Mu,[size(Data,1) 1])];
Sigma = sqrt(prctile(abs(Data),99)+2);
Data = [Data]./repmat(Sigma, size(Data,1),1);
Ye = Data;
Ye(isnan(Ye)) = nanmean(Ye(:));

for nConds=1:4
    for nC = 1:2
        projData(:,nConds,nC,:) = r.project.projSpace(:,1:6)'*squeeze(Ye(:,nConds, nC,:));
    end
end



%%

lineColor = [0 1 1 ; 1 0 0;  0 1 0; 1 0 1];

for nComp = 1: 4
    figure;
for i=1:4
    plot(squeeze(projData(nComp,i,1,300:1100)),'color', lineColor(i,:));
    hold on
    plot(squeeze(projData(nComp,i,2,300:1100)),'--','color',lineColor(i,:));
    hold on;
end
end

%%
%chop r.project.score into the TrajIn and TrajOut and plot them
for nComp = 1: 4
    figure;
for i=1:4
    hold on;
    plot(r.project.TrajIn{1,i}(:,nComp))
    plot(r.project.TrajOut{1,i}(:,nComp),'--')

%     plot(squeeze(projData(nComp,i,1,:)),'color', cols{i});
%     hold on
%     plot(squeeze(projData(nComp,i,2,:)),'--','color',cols{i});
%     hold on;
end
end
% aligned to Reaction time
clear all; close all; clc
% for linux work station 

% temp = load("/home/tianwang/code/behaviorRNN/PsychRNNArchive/stateActivity/gainM.mat").temp;
% checker = readtable("/home/tianwang/code/behaviorRNN/PsychRNN/resultData/checkerPmdGain3Multiply.csv");

% for Tian's PC

% for checkerPmd
% temp = load("D:\BU\ChandLab\PsychRNNArchive\stateActivity\gain.mat").temp;
% checker = readtable("D:/BU/chandLab/PsychRNN/resultData/checkerPmdGain3Additive.csv");

temp = load("D:\BU\ChandLab\PsychRNNArchive\stateActivity\init.mat").temp;
checker = readtable("D:/BU/chandLab/PsychRNN/resultData/checkerPmdInit.csv");

% only choose trials with RT < 1000
rtThresh = checker.decision_time < 1000;
checker = checker(rtThresh, :);
temp = temp(:,:,rtThresh);

[a, b, c] = size(temp);

%% align to RT 
% reaction time; targetOn time and checkerOn time
RT = checker.decision_time;
targetOn = checker.target_onset;
checkerOn = checker.checker_onset;

% real RT, targetOn and checkerOn round to 10's digit
RTR = round(RT, -1);
targetOnR = round(targetOn,-1);
checkerOnR = round(checkerOn + targetOn, -1);
absoluteRTR = round(targetOn + checkerOn + RT, -1);

% left & right trials
right = checker.decision == 1;
left = checker.decision == 0;

% state activity alignes to checkerboard onset, with 200ms before and 1000
% ms after
before = 200;
after = 800;

alignState = [];
for ii = 1 : c
    zeroPt = absoluteRTR(ii)./10 + 1;
    alignState(:,:,ii) = temp(:,zeroPt - before/10+1:zeroPt + after/10, ii);
end

[a, b, c] = size(alignState);


%% reshape data and do pca
test = reshape(alignState, [a, b*c])';

[coeff, score, latent] = pca(test);
orthF = [];
for thi = 1 : c
    orthF(:,:,thi) = (score( (1:b) + (thi-1)*b, :))';
end

%% based on coherence: 2 input-RNN

cc = jet(11);
figure();
coh = unique(checker.coherence_bin);
for ii  = 1 : ceil(length(coh)/2)
    selectedTrials = (checker.coherence_bin == coh(ii) | checker.coherence_bin == -coh(ii));

    leftSelect = selectedTrials & left;
    rightSelect = selectedTrials & right;
    leftTrajAve = mean(orthF(2:4,:,leftSelect), 3);
    rightTrajAve = mean(orthF(2:4,:,rightSelect), 3);

    leftAveRT = mean(absoluteRTR(leftSelect))./10;
    rightAveRT = mean(absoluteRTR(rightSelect))./10;    
    leftAveCheckerOn = mean(checkerOnR(leftSelect))./10;
    rightAveCheckerOn = mean(checkerOnR(rightSelect))./10;
    leftDiff = round(leftAveRT - leftAveCheckerOn);
    rightDiff = round(rightAveRT - rightAveCheckerOn);
    
    % plot left trajs
    plot3(leftTrajAve(1,:), leftTrajAve(2,:),leftTrajAve(3,:), 'color', cc(ii,:), 'linestyle', '--', 'linewidth', 2);
    hold on
    % mark the checkerboard onset
    plot3(leftTrajAve(1,75-leftDiff), leftTrajAve(2,75-leftDiff),leftTrajAve(3,75-leftDiff), 'color', cc(ii,:), 'marker', 'd', 'markerfacecolor',cc(ii,:),'markersize', 10);
    % mark the RT (end time)
    plot3(leftTrajAve(1,75), leftTrajAve(2,75),leftTrajAve(3,75), 'color', 'k', 'marker', '.', 'markersize', 25);
        
    
    % plot right trajs
    plot3(rightTrajAve(1,:), rightTrajAve(2,:),rightTrajAve(3,:), 'color', cc(ii,:), 'linewidth', 2);
    hold on

    % mark the checkerboard onset
    plot3(rightTrajAve(1,75-rightDiff), rightTrajAve(2,75-rightDiff),rightTrajAve(3,75-rightDiff), 'color', cc(ii,:), 'marker', 'd', 'markerfacecolor',cc(ii,:),'markersize', 10);
    % mark the RT (end time)
    plot3(rightTrajAve(1,75), rightTrajAve(2,75),rightTrajAve(3,75), 'color', 'k', 'marker', '.', 'markersize', 25);
      
%     pause()
end

%% based on RT

% the trials definitely have more trials with fastere RT, so the long RT
% trajs are messay

% total data: 500ms before checkerboard onset to 2000ms after checkerboard
% onset. So max RT that can be plotted is 2000ms

% rt = [100 250:50:700 1200];
rt = 100:100:700

cc = jet(length(rt));

% blue to red as RT increases
% left: --; right: -
figure();
for ii  = 1 : length(rt) - 1
    selectedTrials = (rt(ii) < RTR & RTR < rt(ii + 1));

    leftSelect = selectedTrials & left;
    rightSelect = selectedTrials & right;
    leftTrajAve = mean(orthF([1 2 4],:,leftSelect), 3);
    rightTrajAve = mean(orthF([1 2 4],:,rightSelect), 3);
    
    leftAveRT = mean(absoluteRTR(leftSelect))./10;
    rightAveRT = mean(absoluteRTR(rightSelect))./10;    
    leftAveCheckerOn = mean(checkerOnR(leftSelect))./10;
    rightAveCheckerOn = mean(checkerOnR(rightSelect))./10;
    leftDiff = round(leftAveRT - leftAveCheckerOn);
    rightDiff = round(rightAveRT - rightAveCheckerOn);
    
    % plot left trajs
    plot3(leftTrajAve(1,:), leftTrajAve(2,:),leftTrajAve(3,:), 'color', cc(ii,:), 'linestyle', '--', 'linewidth', 2);
    hold on
    % mark the checkerboard onset
    plot3(leftTrajAve(1,75-leftDiff), leftTrajAve(2,75-leftDiff),leftTrajAve(3,75-leftDiff), 'color', cc(ii,:), 'marker', 'd', 'markerfacecolor',cc(ii,:),'markersize', 10);
    % mark the RT (end time)
    plot3(leftTrajAve(1,75), leftTrajAve(2,75),leftTrajAve(3,75), 'color', 'k', 'marker', '.', 'markersize', 25);
        
    
    % plot right trajs
    plot3(rightTrajAve(1,:), rightTrajAve(2,:),rightTrajAve(3,:), 'color', cc(ii,:), 'linewidth', 2);
    hold on

    % mark the checkerboard onset
    plot3(rightTrajAve(1,75-rightDiff), rightTrajAve(2,75-rightDiff),rightTrajAve(3,75-rightDiff), 'color', cc(ii,:), 'marker', 'd', 'markerfacecolor',cc(ii,:),'markersize', 10);
    % mark the RT (end time)
    plot3(rightTrajAve(1,75), rightTrajAve(2,75),rightTrajAve(3,75), 'color', 'k', 'marker', '.', 'markersize', 25);
        

%     title("Left trials: " + sum(leftSelect) + " Right trials: " + sum(rightSelect));

    
%     % 2D plot
%     % plot left trajs
%     plot(leftTrajAve(1,1:leftAveRT), leftTrajAve(2,1:leftAveRT), 'color', cc(ii,:), 'linestyle', '--', 'linewidth', 2);
%     hold on
%     % mark the checkerboard onset
%     plot(leftTrajAve(1,50), leftTrajAve(2,50), 'color', cc(ii,:), 'marker', 'd', 'markerfacecolor',cc(ii,:),'markersize', 10);
%     % mark the RT (end time)
%     plot(leftTrajAve(1,leftAveRT), leftTrajAve(2,leftAveRT), 'color', 'k', 'marker', '.', 'markersize', 25);
%     
%     % plot right trajs
%     plot(rightTrajAve(1,1:rightAveRT), rightTrajAve(2,1:rightAveRT), 'color', cc(ii,:), 'linewidth', 2);
%     hold on
%     % mark the checkerboard onset
%     plot(rightTrajAve(1,50), rightTrajAve(2,50), 'color', cc(ii,:), 'marker', 'd', 'markerfacecolor',cc(ii,:), 'markersize', 10);
%     % mark the RT (end time)
%     plot(rightTrajAve(1,rightAveRT), rightTrajAve(2,rightAveRT), 'color', 'k', 'marker', '.', 'markersize', 25);
%     
%     title("Left trials: " + sum(leftSelect) + " Right trials: " + sum(rightSelect));
    
% %     pause()
end


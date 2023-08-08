%% Create the object of class PMddynamics

N = PMddynamics(M);
N.calcWinCoh(M);

%% Plot Figure 4A-H
dataTable = N.plotComponents
sgt = sgtitle('Figure 4A, H');

%% Now plot trajectories
dataTable.trajectories = N.plotTrajectories('showPooled',1,'showGrid',0,'hideAxes',1);
sgtitle('Figure 4B');

dataTable.kinet = N.plotKinet
sgtitle('Fig. 4C-G');


%% Now plot Supplemental figure where PC4 is shortened.
N.plotTrajectories('showPooled',1,'showGrid',1,'hideAxes',0);


%% Calculate within coh trajectories (Figure 6C-G)
dataTable.trajectories1 = N.plotTrajectories('showPooled',0,'whichCoh',1, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 7C: 90%');

dataTable.trajectories2 = N.plotTrajectories('showPooled',0,'whichCoh',4, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 7C: 31%');

dataTable.trajectories3 = N.plotTrajectories('showPooled',0,'whichCoh',7,'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 7C: 4%');


%%


[~, ~, ~, ~, ~, inputsAndIC] = N.calcInputsAndIC



%% Figure S5A
N.plotVariance


%% Replicate Figure S6, which plots Trial counts for various RT bins
N.plotTrialCounts

%% Replicate Supplemental Figure
N.plotTrajectories('showPooled',1,'showGrid',1,'hideAxes',0);
axis equal
sgtitle('Figure S7');

%% Replicate Figure that uses single neurons (Figure S9)
N2 = PMddynamics(M,'useSingleNeurons',1);
N2.plotTrajectories;
N2.plotKinet


%% Replicates figure that uses non overlapping bins (Figure 5);

N1 = PMddynamics(M,'useNonOverlapping',1);
N1.calcWinCoh(M);
dataTable.noTraj = N1.plotTrajectories;

dataTable.noKinet = N1.plotKinet



[~, ~, ~, ~, ~, nonOverlapping] = N1.calcInputsAndIC

%% Write data to excel files

fileName = '../SourceData.xls'
writetable(dataTable.components,fileName,'FileType','spreadsheet','Sheet','Fig.4a');
writetable(dataTable.trajectories,fileName,'FileType','spreadsheet','Sheet','Fig.4b');
writetable(dataTable.kinet.distance,fileName,'FileType','spreadsheet','Sheet','Fig.4c');
writetable(dataTable.kinet.subspace,fileName,'FileType','spreadsheet','Sheet','Fig.4d');
writetable(dataTable.kinet.align,fileName,'FileType','spreadsheet','Sheet','Fig.4e');
writetable(dataTable.kinet.velocity,fileName,'FileType','spreadsheet','Sheet','Fig.4f');
writetable(dataTable.kinet.speed,fileName,'FileType','spreadsheet','Sheet','Fig.4g');
writetable(dataTable.distance,fileName,'FileType','spreadsheet','Sheet','Fig.4h');


writetable(dataTable.noTraj, fileName,'FileType','spreadsheet','Sheet','Fig.5a');
writetable(dataTable.noKinet.velocity,fileName,'FileType','spreadsheet','Sheet','Fig.5b');
writetable(dataTable.noKinet.subspace,fileName,'FileType','spreadsheet','Sheet','Fig.5c');
writetable(dataTable.noKinet.distance,fileName,'FileType','spreadsheet','Sheet','Fig.5d');
writetable(dataTable.noKinet.align,fileName,'FileType','spreadsheet','Sheet','Fig.5e');


writetable(dataTable.trajectories1,fileName,'FileType','spreadsheet','Sheet','Fig.7c-1');
writetable(dataTable.trajectories2,fileName,'FileType','spreadsheet','Sheet','Fig.7c-2');
writetable(dataTable.trajectories3,fileName,'FileType','spreadsheet','Sheet','Fig.7c-3');

writetable(inputsAndIC.distances, fileName,'FileType','spreadsheet','Sheet','Fig.7d');
writetable(inputsAndIC.avgSel, fileName,'FileType','spreadsheet','Sheet','Fig.7e');
writetable(inputsAndIC.avgLatency, fileName,'FileType','spreadsheet','Sheet','Fig.7f');
writetable(inputsAndIC.avgSlope, fileName,'FileType','spreadsheet','Sheet','Fig.7g');



writetable(nonOverlapping.distances, fileName,'FileType','spreadsheet','Sheet','Fig.7h');
writetable(nonOverlapping.avgSel, fileName,'FileType','spreadsheet','Sheet','Fig.7i');
writetable(nonOverlapping.avgLatency, fileName,'FileType','spreadsheet','Sheet','Fig.7j');
writetable(nonOverlapping.avgSlope, fileName,'FileType','spreadsheet','Sheet','Fig.7k');


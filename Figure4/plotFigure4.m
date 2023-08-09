%% Create the object of class PMddynamics

N30 = PMddynamics(M);
N30.calcWinCoh(M);

%% Plot Figure 4A-H
dataTable = N30.plotComponents
sgt = sgtitle('Figure 4A, H');

%% Now plot trajectories
dataTable.trajectories = N30.plotTrajectories('showPooled',1,'showGrid',0,'hideAxes',1);
sgtitle('Figure 4B');

dataTable.kinet = N30.plotKinet
sgtitle('Fig. 4C-G');



%% Calculate within coh trajectories (Figure 7c)
dataTable.trajectories1 = N30.plotTrajectories('showPooled',0,'whichCoh',1, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 7C: 90%');

dataTable.trajectories2 = N30.plotTrajectories('showPooled',0,'whichCoh',4, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 7C: 31%');

dataTable.trajectories3 = N30.plotTrajectories('showPooled',0,'whichCoh',7,'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 7C: 4%');


%% Figure 7d-g

[~, ~, ~, ~, ~, inputsAndIC] = N30.calcInputsAndIC


%% Figure S5A
dataTable.varExplained = N30.plotVariance


%% Replicate Figure S6, which plots Trial counts for various RT bins
dataTable.trialCounts = N30.plotTrialCounts

%% Replicate Supplemental Figure
N30.plotTrajectories('showPooled',1,'showGrid',1,'hideAxes',0);
axis equal
sgtitle('Figure S7');

%% Replicate Figure that uses single neurons (Figure S9)
NSU = PMddynamics(M,'useSingleNeurons',1);
dataTable.SUtrajectories = NSU.plotTrajectories;
dataTable.SUKinet = NSU.plotKinet


%% Replicates figure that uses non overlapping bins (Figure 5);

Nnon = PMddynamics(M,'useNonOverlapping',1);
Nnon.calcWinCoh(M);
dataTable.noTraj = Nnon.plotTrajectories('showPooled',1,'showGrid',0, 'hideAxes',1);
dataTable.noKinet = Nnon.plotKinet

[~, ~, ~, ~, ~, nonOverlapping] = Nnon.calcInputsAndIC
%% uses 15ms gaussian

dataTable.traj15ms = N15.plotTrajectories;
dataTable.Kinet15ms = N15.plotKinet;
dataTable.var15ms = N15.plotVariance;


%% uses 50 ms boxcar

dataTable.traj50ms = N50.plotTrajectories;
dataTable.Kinet50ms = N50.plotKinet;
dataTable.var50ms = N50.plotVariance;





%% Create the object

N = PMddynamics(M);
N.calcWinCoh(M);

%% Plot Figure 4A-H

N.plotComponents
sgt = sgtitle('Figure 4A, H');


N.plotTrajectories('showPooled',1,'showGrid',0,'hideAxes',1);
sgtitle('Figure 4B');

N.plotKinet
sgtitle('Fig. 4C-G');

%% Calculate within coh trajectories (Figure 6C-G)
N.plotTrajectories('showPooled',0,'whichCoh',1, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 6C: 90%');

N.plotTrajectories('showPooled',0,'whichCoh',4, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 6C: 31%');

N.plotTrajectories('showPooled',0,'whichCoh',7,'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 6C: 4%');


N.calcInputsAndIC



%% Figure S5A
N.plotVariance


%% Replicate Figure S6

N.plotTrialCounts
%% Replicate Figure S7

N.plotTrajectories('showPooled',1,'showGrid',1,'hideAxes',0);
axis equal
sgtitle('Figure S7');

%% Replicate Figure that uses single neurons (Figure S9)

N2 = PMddynamics(M,'useSingleNeurons',1);
N2.plotTrajectories;
N2.plotKinet


%% Replicates figure that uses non overlapping bins (Figure S10);

N1 = PMddynamics(M,'useNonOverlapping',1);
N1.plotTrajectories;
N1.plotKinet


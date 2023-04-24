%%

N = PMddynamics(M);

%%

% Plot Figure 4A
N.plotComponents
sgt = sgtitle('Figure 4A, H');
%%
% Plot Figure 4B
N.plotTrajectories('showPooled',1,'showGrid',0,'hideAxes',1);
sgtitle('Figure 4B');

N.plotTrajectories('showPooled',1,'showGrid',1,'hideAxes',0);
axis equal
sgtitle('Figure S7');


%% Plot Figure 4C-H

N.plotKinet

sgtitle('Fig. 4C-G');

%%


N.calcWinCoh(M);
%%
N.plotTrajectories('showPooled',0,'whichCoh',1, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 6C');

N.plotTrajectories('showPooled',0,'whichCoh',4, 'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 6C');

N.plotTrajectories('showPooled',0,'whichCoh',7,'showGrid',0, 'hideAxes',1);
sgtitle('Fig. 6C');

%% Replicates

N1 = PMddynamics(M,'useNonOverlapping',1);
N1.plotTrajectories;
N1.plotKinet
%%

N2 = PMddynamics(M,'useSingleNeurons',1);
N2.plotTrajectories;
N2.plotKinet
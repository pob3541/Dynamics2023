% load data for Figure 8
load Figure8data.mat

% process data for Figure 8
[r] = POA(outcome); 

% 8a
r.plotComponents(); 

% 8b
r.plotTrajectories();

% 8c & e
r.plotKinet();

% 8d
r.plotDecoder();




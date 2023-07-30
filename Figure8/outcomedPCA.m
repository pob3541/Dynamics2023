
load('/net/derived/pierreb/OutcomeMat.mat');

OutcomeMat = permute(OutcomeMat, [2 3 4 1]);

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Outcome ', 'Choice', 'Condition-independent', 'Interaction'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;


rawDataOutcome = double(OutcomeMat(:,:,:,1:600));
rawDataOutcome(isnan(rawDataOutcome)) = nanmean(rawDataOutcome(:));
tic
[W,Voutcome,whichMarg] = dpca(rawDataOutcome, 20, ...
    'combinedParams', combinedParams);

explVar = dpca_explainedVariance(rawDataOutcome, W, Voutcome, ...
    'combinedParams', combinedParams);


dpca_plot(rawDataOutcome, W, Voutcome, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);




%%

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Choice ', 'RT', 'Condition-independent', 'Interaction'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;



rawData = permute(M.rt.FR,[3 2 1 4]);
rawData = double(rawData(:,:,:,1:600));
rawData(isnan(rawData)) = nanmean(rawData(:));
tic
[W,V,whichMarg] = dpca(rawData, 20, ...
    'combinedParams', combinedParams);


explVar = dpca_explainedVariance(rawData, W, V, ...
    'combinedParams', combinedParams);


dpca_plot(rawData, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);

VRT = V;

%%

180*subspace(Voutcome(:,1), V(:,1))/pi



%%


180*subspace(Voutcome(:,4), V(:,2))/pi


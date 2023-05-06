# Code for recreating figures from the manuscript
> P. O. Boucher, T. Wang, L. Carceroni, G. Kane, K. V. Shenoy, C. Chandramouli.
> **** Initial conditions in dorsal premotor cortex covary with reaction time, are altered by trial outcome, and combine with sensory evidence to induce > decision-related dynamics ****
Tested in Matlab R2021b

Data needed:
- Data is available on Dryad at this url

https://datadryad.org/stash/share/xZzCe2AjAL8UBipbAgG1EX1R9abPc7pJ8zCYgU728GE

Toolboxes needed: 
- Curve Fitting Toolbox
- Statistics and Machine Learning Toolbox
- Bioinformatics Toolbox

For the repository to work on your computer please add the Dynamics2023 folder with all subfolders to your MATLAB path (add utils separately). 

## Figure 2: Behavior

Open figure2.m. Run this script to load behavioral data for both monkeys. Script then displays psychometric curves (percent responded red as a function of signed coherence), reaction time (RT) curves as a function of signed coherence, and boxplots of RTs organized by stimulus coherence for both monkeys.

## Figure 3: Heterogeneous and time-varying activity of PMd neurons 
 
If you want to display the first unit, for example, presented in Figure 3 run the following line in MATLAB's command prompt:
 >Fig3Neurons(1)

The number corresponds to the order of presentation in the figure. You can plot all 5 units in this manner (e.g., Fig3Neurons(2) will plot the second and so on). Plotted units are shown organized by coherence and RT, as well as aligned to cue and movement onset. Scaling may be slightly different between the figures in the paper and what is plotted from MATLAB.

## Figure 4: Initial conditions predict subsequent dynamics and RT

Load Figure4Data.mat from Dryad_Data. Open Figure4\plotFigure4.m.

Running the following code will initialize the data to recreate all of the plots in Figure 4:
> N = PMddynamics(M); 
> N.calcWinCoh(M);


 The following commands will plot all parts of Figure 4: 

4A & H
> N.plotComponents


4B
> N.plotTrajectories('showPooled',1,'showGrid',0,'hideAxes',1); 

4C-G
> N.plotKinet

- A sister plot to the average raw speed plot is included here. This sister plot shows how the raw firing rate speed changes over the course of the trial organized by RT bin. In short, it's the Euclidean distance between each adjacent time points, so how firing rate changes in state space over time. In essence, firing rates associated with faster RT bins move through state space faster than firing rates in slower RT bins [May want to include that's the average prestimulus speed in Fig 4G.]


## Figure 5: Single-trial analysis and decoding
Load regressions.mat from /Figure5 into your workspace.

Running the following code will initialize the data to recreate all of the plots in Figure 5. 
> D= PMddecoding(regressions) 

The following commands will plot all parts of Figure 5: 

5A
>D.plotRTLFADS() 

5B
>D.plotChoiceLFADS()

5C & E
>D.plotR2() 

5D & F
>D.plotAcc() 

## Figure 6: Initial conditions and inputs contribute to choice-related dynamics

Load Figure4Data.mat from Dryad_Data. Open Figure4\plotFigure4.m.

6C
>N.plotTrajectories('showPooled',0,'whichCoh',1, 'showGrid',0, 'hideAxes',1);
>N.plotTrajectories('showPooled',0,'whichCoh',4, 'showGrid',0, 'hideAxes',1);
>N.plotTrajectories('showPooled',0,'whichCoh',7,'showGrid',0, 'hideAxes',1);

6D-G
>N.calcInputsAndIC

## Figure 7: Outcome changes initial conditions

Load Figure7Data.mat from Dryad_Data. Open Figure7\@POA\POA.m.

Running the following command in POA.m will initialize the data to recreate all of the plots in Figure 7. 
>[r] = POA_plotting(outcome) 

7A
>r.plotComponents()

7B
>r.plotTrajectories()

7C & E
>r.plotKinet()

7D
>r.plotDecoder()

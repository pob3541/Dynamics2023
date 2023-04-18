﻿# Code for recreating figures from the manuscript
> P. O. Boucher, T. Wang, L. Carceroni, G. Kane, K. V. Shenoy, C. Chandramouli.
> **Neural population dynamics in dorsal premotor cortex underlying a reach
decision**
>  2022, bioRxiv, [https://doi.org/10.1101/2022.06.30.497070](https://doi.org/10.1101/2022.06.30.497070)



Tested in Matlab R2021b
Toolboxes needed: 
- Curve Fitting Toolbox
- Statistics and Machine Learning Toolbox

Download the associated data files for this repository from Dryad at this doi:
- zip file (~11 GB).

For the repository to work on your computer add the subfolders for any sub functions. 


## Figure 2: Behavior

Open figure2.m. The first section of this script loads and displays the accuracy and reaction time (RT) data. The second section adds the boxplots of the RT data to the same figures.

## Figure 3: Heterogeneous and time-varying activity of PMd neurons 
 
If you want to display the first unit, for example, presented in Figure 3 run the following line in Matlab's command prompt:
 >Fig3Neurons(1)

The number corresponds to the order of presentation in the figure. Plotted units are shown organized by coherence and RT, as well as aligned to cue and movement onset. Scaling may be slightly different between the the figures in the paper and what is plotted from Matlab.

## Figure 4: Initial conditions predict subsequent dynamics and RT

Load MonkeyFRs.mat from DynamicsData/Fig4_6 into your workspace.

Running the following code will initialize the data to recreate all of the plots in Figure 4:
> [r, temp] = PMddynamics(M) 

 The following commands will plot all parts of Figure 4: 

4A & H
>r.plotComponents() 

4B
> r.plotTrajectories() 

4C, D, E, F, G
> r.plotKinet() 

- A sister plot to the average raw speed plot is included here. This sister plot shows how the raw firing rate speed changes over the course of the trial organized by RT bin. In short, it's the Euclidean distance between each adjacent time points, so how firing rate changes in state space over time. In essence, firing rates associated with faster RT bins move through state space faster than firing rates in slower RT bins [May want to include that's the average prestimulus speed in Fig 4G.]


## Figure 5: Single-trial analysis and decoding
Load classifier.mat, regression.mat, result.mat, t_14October2013_345678.mat from DynamicsData/Fig5 into your workspace.

Running the following code will initialize the data to recreate all of the plots in Figure 5. 
> D= PMddecoding(decode) 

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

Load MonkeyFRs.mat from DynamicsData/Fig4_6 into your workspace.

For Fig 6C in order to plot the trajectories within a coherence use the following code as an example which will plot the trajectory for the 90% coherence: 

> r.plotTrajectories('showPooled',false,'whichCoh',1) 

To see the 31% and 4% coherences as plotted for Fig 6C change the 'whichCoh' variable to 4 and 7 respectively. 

The first section of calcSlopeV.m plots Fig 6D or the Euclidean distance in neural state space between left and right reaches within a stimulus coherence. The second section of code calculates the slope and the latency and the third chunk of code then plots Fig 6E.

## Figure 7: Outcome changes initial conditions

Load Outcome.mat from DynamicsData/Fig7 into your workspace.

Running the following command in POA.m will initialize the data to recreate all of the plots in Figure 7. 
>[r] = POA(AllSess) 
>
The following commands will plot all parts of Figure 7: 

7A
>r.plotComponents()

7B
>r.plotTrajectories()

7C & E
>r.plotKinet()

7D
>r.calcDecode(AllSess) 
>r.plotDecoder()
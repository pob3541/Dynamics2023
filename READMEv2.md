# Dataset for recreating figures from Boucher et al., 2023
---
Experimental data used to construct the figures found in (tested in Matlab R2021b):

> P. O. Boucher, T. Wang, L. Carceroni, G. Kane, K. V. Shenoy, C. Chandramouli.
> *** Initial conditions combine with sensory evidence to induce decision-related dynamics in premotor cortex ***


Experimental data ([doi:10.5061/dryad.9cnp5hqn0](doi:10.5061/dryad.9cnp5hqn0)) and scripts ([https://github.com/pob3541/Dynamics2023](https://github.com/pob3541/Dynamics2023)) are organized based on the order of figures in the manuscript.

Download Github repository:        `git clone https://github.com/pob3541/Dynamics2023.git`

For the repository to work on your computer please add the Dynamics2023 folder with all subfolders to your MATLAB path (add utils separately).

Toolboxes needed: 
- Curve Fitting Toolbox
- Statistics and Machine Learning Toolbox
- Bioinformatics Toolbox


## Description of the data and file structure

To make replotting the figures as easy as possible a script entitled 'plotAllFigures.m' can be used as a guide to open scripts to plot specific figures (e.g., 'plotFigure2.m').

### Figure 2: Psychometric curves for the monkey, and RT and box plots

Open 'plotFigure2.m'. Run this script to load behavioral data for both monkeys. Script then displays psychometric curves (percent responded red as a function of signed coherence), reaction time (RT) curves as a function of signed coherence, and boxplots of RTs organized by stimulus coherence for both monkeys.

### Figure 3: Heterogeneous and time-varying activity of PMd neurons 
 
Open 'plotFigure3.m'. If you want to display the first unit presented in Figure 3 run the following command:
 >Fig3Neurons(1)

The number corresponds to the order of presentation in the figure. You can plot all 6 units in this manner (e.g., Fig3Neurons(2) will plot the second and so on). Plotted units are shown organized by coherence and RT, as well as aligned to cue and movement onset. Scaling may be slightly different between the figures in the paper and what is plotted from MATLAB.

## Figure 4: Initial conditions predict subsequent dynamics and RT

Open 'plotFigure4_5_7.m'. Load Figure4_5_7data.mat from DryadData. 

Running the following code will initialize the data to recreate all of the plots in Figure 4:
> N30 = PMddynamics(M); 
> N30.calcWinCoh(M);


The following commands will plot all parts of Figure 4: 

4A & H
> N30.plotComponents;

4B
> N30.plotTrajectories('showPooled',1,'showGrid',0,'hideAxes',1); 

4C-G
> N30.plotKinet

- A sister plot to the average raw speed plot is included (bottom right). This plot shows change in firing rate (Euclidean distance between adjacent time points) averaged across trials and within RT bins.  Esentially, firing rates associated with faster RT bins move through state space faster than firing rates in slower RT bins.

## Figure 5: Replicates main findings in Figure 4 using non-overlapping RT bins

Open 'plotFigure4_5_7.m'. Load Figure4_5_7data.mat from DryadData. 

Running the following code will initialize the data to recreate all of the plots in Figure 5:
> Nnon = PMddynamics(M,'useNonOverlapping',1);
> Nnon.calcWinCoh(M);

The following commands will plot all parts of Figure 5: 

5A
> Nnon.plotTrajectories('showPooled',1,'showGrid',0, 'hideAxes',1);

5B-E
> Nnon.plotKinet;



## Figure 6: Single-trial analysis and decoding
Open 'plotFigure6.m'. Load regressions.mat from DryadData. 

Running the following code will initialize the data to recreate all of the plots in Figure 6. 
> D= PMDdecoding(regressions) 

The following commands will plot all parts of Figure 6: 

6A
>D.plotRTLFADS() 

6B
>D.plotChoiceLFADS()

6C & E
>D.plotR2() 

6D & F
>D.plotAcc() 

## Sharing/Access information

This is a section for linking to other ways to access the data, and for linking to sources the data is derived from, if any.

Links to other publicly accessible locations of the data:
  * 

Data was derived from the following sources:
  * 


## Code/Software

This is an optional, freeform section for describing any code in your submission and the software used to run it.

Describe any scripts, code, or notebooks (e.g., R, Python, Mathematica, MatLab) as well as the software versions (including loaded packages) that you used to run those files. If your repository contains more than one file whose relationship to other scripts is not obvious, provide information about the workflow that you used to run those scripts and notebooks.
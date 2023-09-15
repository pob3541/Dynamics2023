# Data for "Initial conditions combine with sensory evidence to induce decision-related dynamics in premotor cortex"

—

This Dryad repository contains data used to construct the figures for "Initial conditions combine with sensory evidence to induce decision-related dynamics in premotor cortex". 

Experimental data is organized based on the figures in the manuscript, and code to reproduce the figures can be found on Github ([https://github.com/chand-lab/Dynamics2023](https://github.com/chand-lab/Dynamics2023)).

Please see below for further details about the dataset, see the Dryad description ([https://doi.org/10.5061/dryad.9cnp5hqn0](https://doi.org/10.5061/dryad.9cnp5hqn0)) or the article itself for further methodological and analytical details.

**Description of the data and file structure**

This dataset contains various .mat files for recreating the 8 main and 22 supplementary figures in the Nature Communications paper (Boucher PO, Wang T, Carceroni L, Kane G, Shenoy KV, Chandramouli C, _Initial conditions combine with sensory evidence to induce decision-related dynamics in premotor cortex_).

These mat files are generally structures that are then used for subsequent analyses in the code provided in the freely available Github repository ([https://github.com/chand-lab/Dynamics2023](https://github.com/chand-lab/Dynamics2023)).  The most relevant fields for the analyses are described in further detail below.

**File/Folder Details**

**Fig2 Folder (Github)**

_figTData.mat & figOData.mat_ describe the behavior of the monkeys in the task. 

* monkey - first letter of the monkey's name (either monkey T or monkey O)
* signedColorCoherence - signed color coherence values of stimuli (negative values correspond to green checkerboards)
* thresholds:
    * 1st column - discrimination thresholds (per session) measured as the color coherence level at which the monkey made 81.6% correct choices.
    * 2nd column - Slopes of the Weibull distribution function fits
* fitquality - the fit of the Weibull distribution function
* combined - contains all the trials pooled over all sessions with various fields in order (number of red squares, color chosen (0 is green, 1 is red), RT, left target color, right target color, and sessionId)
* rawdata.RT - average RT by session (rows) and signed coherence (columns)
* rawData.pRed - percentage responded red by session (rows) and signed coherence (columns)
* params - parameters used to plot the figures

**Figure3 (Dryad Data)**

Data in _HetNeurons.mat_ is used for plotting the PSTHs in figure 3. The HetNeurons.mat file contains a structure `Data’ with 8 units. Each element of this structure contains several fields that can be used for plotting PSTHs.  

Data(1).Unit

* Monkey - first letter of the monkey's name
* Date - date unit was recorded
* Ch - channel unit was recorded on
* Unit - unit number
* Choice - column with choice per trial (1 - left  2 - right choice)
* Coherence - seven levels of coherence from 4 to 90% , which reflects different stimulus difficulties
* RT - RT per trial
* bound1 - time bounds for plotting according to cue or movement onset
* bound2 - time bounds for plotting according to cue or movement onset
* FRs - structure containing the firing rates for units aligned to Cue (Cue) or Movement (Move) onset. Within either Cue or Move fields of FRs the firing rates are smoothed with either a 30 ms Gaussian (gauss30), 15 ms Gaussian (gauss15) or 50 ms Boxcar (box50) kernel.

**Figure4_5_7 (Dryad Data)**

_Figure4_5_7data.mat is a large mat file that is nearly 15 GB in size._ When loaded it contains a structure M with two fields, coherence and rt. coherence and rt  themselves are structures with many sub fields including FR (firing rates aligned to stimulus onset), FRm (firing rates aligned to movement onset), etc. These firing rates are typically organized as Neurons x RT bins x choice x time. Typical sizes would be 996 x 11 x 2 x 1801. Firing rates are derived from spiking activity smoothed with a 30 ms Gaussian kernel. The firing rates are used for subsequent calculation of PC trajectories and these PC trajectories are then used in KiNeT analyses etc.  The fields most useful for analysis and replicating results in this paper are as follows. 

coherence is a structure with the following fields.



* FR - a 7 x 2 x 996 x 1801 matrix (coherence x choice x units x time in trial) of firing rates aligned to stimulus onset
* FRm - 7 x 2 x 996 x 1802 matrix (coherence x choice x units x time in trial) of firing rates aligned to movement onset
* RTall - RTs organized into a 996 x 2 x 7 matrix (units x choice x coherence) 
* tM - timepoints for movement aligned data
* tS - timepoints for cue aligned data 
* NeuronIds - ids for units (session and channel and unit id)
* RTlims - lower (1st row) and upper (2nd row) bounds used to define RT bins

rt is a structure with the following fields



* FR - a 15 x 2 x 996 x 1801 matrix (RT bins x choice x units x time in trial) of firing rates aligned to stimulus onset
* FRm - 15 x 2 x 996 x 1802 matrix (RT bins x choice x units x time in trial) of firing rates aligned to movement onset
* bsFR -  bootstrapped firing rates size of (996 x 15 x 2 x 50 x 1801). 50 bootstraps. It is a companion for the FR field 
* bsFRm - bootstrapped firing rates for each unit aligned to movement
* RTall - Contains RT for each of the conditions of the FR matrix
* FRnoise - contains the difference in FR between two arbitrarily selected trials 
* tM -  timepoints for movement aligned data
* tS - timepoints for cue aligned data
* NeuronIds -  ids for units (session and channel and unit id)
* RTlims - lower and upper Limits for each RT bin
* TrialCounts - Number of trials for each RT bin and choice
* AllFR -	Contains FR organized by RT for each of the coherences aligned to checkerboard
* AllFRm - Contains FR organized by RT for each of the coherences aligned to movement
* outSpace - 996 x 996 outcome covariance matrix identified by PCA on trial outcome and choice

				
**Figure6 (Dryad Data)**
_regressions.mat_ contains 4 structures used for replicating the LFADS trajectories, accuracy, and variance explained plots from Figure 6. 


classifier (1 x 51 struct) - contains classifier data from 51 sessions and is used to calculate the mean accuracy.


* name - name of the data file 
* accuracy - 90 x 1 (time bins). Decoding accuracy of one session
* shuffled_accuracy - 500 x 90 (shuffled times  x time bins). Accuracy of 500 shuffles 
* shuffled_bound_accuracy - 2 x 90 (2 bounds x time bins). 1 and 99 percentile bound of shuffled accuracy
* trialNum - the total number of trials within one session	
* usedTrialNum - the number of trials used in decoding analysis

Linreg (1 x 51 struct) - contains regression data from 51 sessions and is used to calculate mean R<sup>2</sup>



* c1R2 - 90 x 1 (time bins). R<sup>2</sup> of left choice 
* shuffledC1R2 - 500 x 90 (shuffled times  x time bins). 500-time shuffled R<sup>2</sup> of left choice 
* shuffledBoundC1R2 - 2 x 90 (2 bounds x time bins). 1 and 99 percentile bound of shuffled R<sup>2</sup>
* C2R2 - 90 x 1 (time bins). R<sup>2</sup> of right choice 
* shuffledC2R2 - 500 x 90 (shuffled times  x time bins). Shuffled R<sup>2</sup> of right choice 
* shuffledBoundC2R2 - 2 x 90 (2 bounds x time bins). 1 and 99 percentile bound of shuffled R<sup>2</sup>
* trialNum - the total number of trials within one session

lfadsR (struct) - contains data to plot LFADS trajectories from the Oct 14th, 2013 session



* factors - 8 x 180 x 1814 (factors x time x trials), latent factors generated by LFADS

	

raw - contains raw data from the Oct 14th, 2013 session



* dat (1 x 1814 struct)
    * trialID -  trial ID 
    * spikes - 23 x 1802 (units x time) spikes from 23 units recorded per trial
    * RT - RT of the trial
    * delay -  time between target onset and checkerboard onset
    * Cue - number of red squares in the checkerboard
    * GlobalTrialId - the global trial id
    * choice - choice per trial (1 - left  2 - right choice)
    * condId - level of coherence (1 - 90% … 7 - 4%)

			

			

**Figure8 (Dryad Data)**

_Figure8data.mat_ is ~16 GB large. When loaded it contains a structure, outcome, with 12 fields described below. These fields broadly contain firing rates generally organized by trial outcome and other behavioral measures also organized around trial outcome. The firing rates are typically organized as time x units x outcome x choice. Typical sizes would be 1801 x 996 x 4 x 2. Firing rates are derived from spiking activity smoothed with a 30 ms Gaussian kernel. The firing rates are used for subsequent calculation of PC trajectories and these PC trajectories are then used in KiNeT analyses etc.   

outcome 


* errInd - 2-field structure containing trial IDs and RTs for CC EC sequences
    * errCorrMatchAll - 141 x 1 cell array containing CC EC sequence trial IDs
    * PES_CCEC_RT - 141 x 1 cell array containing RTs for CC EC sequences
* CCE_ECC - 4-field structure containing data for replotting CCE ECC figures
    * trials - 141 x 1 cell matrix containing CC EC sequence trial IDs that derive from CCE and ECC sequences
    * outcomePCA_trunc - 1801 x 996 x 4 x 2 matrix (time x units x outcome x choice) of firing rates organized by outcome (CCE ECC sequences) and choice, aligned to stimulus onset 
    * outcomePCA_trunc_Boot - 1801 x 996 x 4 x 2 x 50 matrix (time x units x outcome x choice x bootstraps) of bootstrapped firing rates organized by outcome (CCE ECC sequences) and choice, aligned to stimulus onset 
    * outcomePCA_trunc_Shuf - 1801 x 996 x 4 x 2 x 50 matrix (time x units x outcome x choice x bootstraps) of shuffled firing rates organized by outcome (CCE ECC sequences) and choice, aligned to stimulus onset 
* b - 141 x 1 cell matrix containing all RTs per session (141 sessions) and save tag (number of cells in a session) 
* outcomePCA_trunc - 1801 x 996 x 4 x 2 matrix (time x units x outcome x choice) of firing rates organized by outcome (CC EC sequences) and choice, aligned to stimulus onset 
* outcomePCA_trunc_Boot - 1801 x 996 x 4 x 2 x 50 matrix (time x units x outcome x choice x bootstraps) of bootstrapped firing rates organized by outcome and choice (CE EC sequences), aligned to stimulus onset
* decode - 5 x 1 structure containing variables needed for the outcome decoder figure
    * binnedSpikeTimes - 51 x cell array containing 51 sessions and their save tags - 72 x 996 x 13 (x units)
    * sessions - number of the session when sessions are organized by monkey O then T
    * binAcc - 51 x 1 cell array containing per session (51), per bin (72) accuracy with save tags organized into cells
    * binAcc2 - 51 x 1 cell array containing per session (51), per bin (72) accuracy with save tags organized into columns
    * bins - number of bins to use for the decoder (25 ms/bin)

* Y_logic - 141 x 1 cell matrix containing trial outcomes (1 - correct, 0 - incorrect) per session (141 sessions) and save tag (number of cells in a session)
* pcaCohRT - 3 x 1 structure containing data used for plotting supplementary PCA with coherence and RT data. RT/coherence groupings break down as follows: easiest coherences (90%, 60%, 40%), medium difficulty coherences (31% 20%), and the hardest coherences (10%, 4%) paired with fast RT (300 - 400 ms), medium RT (400 - 525 ms) and slow RT bins (500 - 1000ms). 
    * FR_CohRT4D_trunc - 1801 x 996 x 9 x 2 matrix (time x units x RT/coherence x choice) of firing rates organized by grouped RT/coherence and choice
    * medRTs - median RTs per RT/coherence grouping
    * CohRTbinRTs - 9 x 1 cell array for all RTs per RT/coherence grouping
* noise - structure containing 8 fields for data derived from a PCA of noise
    * TrajIn - 1 x 11 cell array containing trajectory data of noise from 11 RT bins for left reaches 
    * TrajOut - 1 x 11 cell array containing trajectory data of noise from 11 RT bins for right reaches
    * eigenVectors - the eigenvectors from a noise PCA
    * score - the score from a PCA of noise
    * latentActual - the latent values from a PCA of noise 
    * varExplained - percent variance explained of the latent variables
    * tData - 1 x 11 cell array of time points for each of the trajectories from 11 RT bins 
    * covMatrix - 996 x 996 covariance matrix of noise concatenated by 11 RT bins and choice  
* PCAm - 2-field structure containing data for plotting PCA data aligned to movement onset
    * outcomePCAm_trunc -  1801 x 996 x 4 x 2 matrix (time x units x outcome x choice) of firing rates organized by outcome (CE EC sequences) and choice, aligned to movement onset
    * outcomePCAm_trunc_Boot - 1801 x 996 x 4 x 2 x 50 matrix (time x units x outcome x choice x bootstraps) of bootstrapped firing rates organized by outcome (CE EC sequences) and choice, aligned to movement onset
* projRT - 3-field structure containing data for plotting subspace projections
    * RTPCAeigenVs - eigenvectors from a PCA of firing rates organized by 11 RT bins and choice
    * RTcovMatrix - 996 x 996 covariance matrix of firing rates concatenated by 11 RT bins and choice 
    * RTlatents - the latent values from a PCA of firing rates organized by 11 RT bins and choice
* bx - 3-field structure containing behavioral data for plotting streaks and CC EC RTs
    * Y_logic - 141 x 1 cell matrix containing trial outcomes (1 - correct, 0 - incorrect) per session (141 sessions) 
    * RT - 141 x 1 cell matrix containing RT per trial per session (141 sessions) 
    * ST_Logic - 141 x 1 cell matrix containing save tag logic (1 - trial with neural data, 0 - trial without neural data) per session (141 sessions) 

**FigureS11 (Dryad Data)**

The .mat files in this folder follow the same data structure as in _Figure4_5_7.mat_. Thus please refer back to that part of the readme to get the breakdown of the M structure. The difference between these data sets is that the firing rates in 15msGauss.mat are derived from spiking activity smoothed with a 15 ms Gaussian kernel and firing rates in 50msBoxcarFRs.mat are derived from spiking activity smoothed with a 50 ms boxcar kernel. 

_15msGaussFRs.mat_ ~10.6 GB

_50msBoxcarFRs.mat_ ~7.2 GB

**FigureS12 (Dryad Data)**

This data is used for the tensor component analysis (TCA) in Figure S12. The directory contains files for each session with the name formatted as: 

_date_dataStructs.mat_

In the TCA code we use the RTs, choice and  nSquares from the dataStruct. We also use the RawData structure which contains binned spike counts (50 ms bins). We use data from every 50 ms for subsequent TCA analysis.

dat - struct with 7 fields

* trialID - a number for each trial in the dat structure.
* spikes - units x time 
* RT - trial RT
* delay - delay between target onset and checkerboard onset
* Cue - Number of red squares in the checkerboard
* GlobalTrialId - The global trial id for the session 
* choice - trial choice (1 - left, 2 - right)

dataStruct - struct with 11 fields

* RawData 
    * Left - binned spike counts (50 ms binned with 1 ms shift) for left trials
    * Right - same for right trials
    * timeAxis - axis for the binned spike counts. 
* lims - [prestimulus time, poststimulus time]
* Info
    * Left/Right
        * goodRTs - RTs of trials
        * nSquares - number of red squares
        * GlobalTrialId - global trial id
        * choice - trial choice (1 - left, 2 - right)
        * targetConfig - whether the left target is red or green (it is obtained by subtracting left target - right target), 1 means left target is green, and -1 means left target is red.
        * colorChosen - the color of the target chosen
        * Delay - the delay between target onset and checkerboard onset
        * EyePos - (trials x trial time) x,y eye position in pixels 
        * HandPos - (trials x trial time) x,y hand position in  mm
        * velocity - peak speed on each trial
        * pV - proportion responded red
        * Sanity - is a table with the left target, right target, action choice, color choice, outcome, Cue, and Trial Id. Used for double checking that the code etc is right.
* binSize - the size of the box car filter in ms
* filter - ‘g’  (Gaussian)
* gaussSd - Gaussian kernel in seconds (if used)
* channelsToInclude - the relevant channels for this session. This is linked to the unitsToInclude
* unitsToInclude - the relevant units for this session
* binned
    * Left - (time x units x left trials)
    * Right - (time x units x right trials)
* Red/Green
    * Left - All left trials for red (Green) trials
    * RTL - RT for left trials of that color
    * Right - All right trials 
    * RTR - RT for right trials.

nL - number of left trials

nR - number of right trials

**FigureS13 (Dryad Data)**

Used for fits of the LDS.

_monkeyInitial_date_saveTags.mat_

forGPFA - struct with 6 fields

* dataStruct - struct with 11 fields (near identical to dataStruct in S12)
* dat - struct with 8 fields (near identical to dataStruct in S12 with an additional field)
    * condId - trial stimulus coherence (1 - 90% … 7 - 4%)
* nL - number of left trials
* nR - number of right trials	
* identifier - session date
* metaData - data associated with the session
    * monkey - monkey intial
    * sessionId - session ID
    * sessionName - session date
    * saveTags - save tags associated with session

nL - number of left trials

nR - number of right trials

**FigureS14 (Dryad Data)**

This folder contains session data with 9 mat files from monkey O and 7 from monkey T. All the mat files have the same structure.

_O/Tsess#.mat_

* choice - column with choice per trial (1 - left  2 - right choice)
* conditionIds - column with level of coherence (1 - 90% … 7 - 4%)
* factors - 8 x 180 x 762 (LFADS factor x timepoints x trials) matrix of LFADS factors 
* rates -  14 x 180 x 762 (LFADS units x timepoints x trials) matrix of LFADS reconstructed firing rates 
* rawCounts - 14 x 1802 x 762 (units x timepoints x trials) matrix of raw unit firing rates
* RT -  column with RT per trial
* subject - session data (monkey initial_session date_savetags.mat) 
* time - timepoints for LFADS 
* trainInds - trial numbers used to train LFADS model
* validInds - trial numbers used to validate LFADS model 

**FigureS16 (Dryad Data)**

_decoderbyRTBins.mat_

classifier - 1 x 51 structure (51 sessions) containing data to replot S16c


* name - name of file structure and the session data is from 
* accuracy - 90 x 11 (binned spiking activity x RT bins) matrix containing accuracy data per trial time bin (rows) and 11 RT bins (columns) 

**FigureS17 (Dryad Data)**

_decoderbyRTBinsAllCoh.mat_

allDecodes - 1 x 7 structure (7 coherences) containing data to replot S17a, b

* classifier
    * name - name of file structure and the session data is from 
    * accuracy - 90 x 3 (binned spiking activity x RT bins) matrix containing accuracy data per trial time bin (rows) and 3 RT bins (columns) 

**FigureS18 (Dryad Data)**

_14October2013_Tiberius.mat_

Data from 1 session with monkey T. This dataset exemplifies how raw session data is stored. This session has 23 units and is used for plotting all of the LFADS trajectories (Figures 6a,b and S18d). 

 

Trials - 1 x 1980 struct with 117 fields (relevant fields for plotting S18d detailed below)



* GlobalTrialId - trial ID in the session
* TrialOutcome - whether the trial has a correct or an  incorrect response

		

## Code/Software

We highly recommend that the files provided in the Dryad Dataset are used in concert with our Github repository which provides all the code for replicating the main results of the manuscript as well as all the supplementary information. Code is available at [https://github.com/chand-lab/Dynamics2023](https://github.com/chand-lab/Dynamics2023) and this is a publicly available repository. Interested users can then expand on this code and derive new analyses as needed or test new hypotheses.

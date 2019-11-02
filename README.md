## Supporting files for manuscript: Bringing High-Performance Computing into EEGLAB: The Open EEGLAB Portal
Supporting files (not data) for the manuscript: 

**Bringing High-Performance Computing into EEGLAB: The Open EEGLAB Portal** by Ramon Martinez-Cancino, Dung Truong, Fiorenzo Artoni, Kenneth Kreutz-Delgado, Amitava Majumdar, Subhashini Sivagnanam, Kenneth Yoshimoto, Scott Makeig and Arnaud Delorme.(In preparation)


## Content
1. Folder *oep_runica*: Sample job used in the manuscript. It contains the script and data to run in NSG.
2. Folder *oep_runica_plugin*: Sammple plug-in  featuring *nsgportal* command-line tools
3. Folder *relica_local_test*: Script for testing RELICA (NSG-capable) performance. Saves the time and computer characteristics where the test is performed.
4. Folder *wh_data* with the scripts for:
    1. Import the EEG data from the raw (.fif) files (*wh_extracteegsubj11.m*)
    2. Preprocessing and saving the EEG data in its final format for the job test (*wh_preprocessing_subj11.m*).
    3. Running data import and processing scripts (*wh_subj11_runall.m*). This is the one that should be run by the users.
                                          
The data used here correspond to the first run from subject 11 in the dataset published by:
Henson, R.N., Wakeman, D.G., Litvak, V. & Friston, K.J. (2011).
A Parametric Empirical Bayesian framework for the EEG/MEG inverse
problem: generative models for multisubject and multimodal integration.
Frontiers in Human Neuroscience, 5, 76, 1-16.
The data was obtained from the OpenNeuro project (https://www.openneuro.org). Accession #: ds000117.




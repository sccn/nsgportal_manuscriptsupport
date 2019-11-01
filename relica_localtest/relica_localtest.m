% Script running RELICA on a local computing resource for measuring
% performance.
 
% Make relica output folder 
mkdir('relicaoutput'); 

% Launch eeglab
eeglab

% Load dataset wh_sub11_preproc.set
EEG = pop_loadset('wh_sub011_proc.set'); 

tic % Start timer
EEG = pop_relica(EEG,100,'runica','point', 'relicaoutput'); % Running RELICA
elapsedtime = toc; % Elapsed time since timer started

% Saving elapsed time
save('elapsedtime.mat', 'elapsedtime');


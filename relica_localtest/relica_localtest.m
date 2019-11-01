% Script running RELICA on a local computing resource for measuring
% performance.
 
% Get system info
system = cpuinfo;

% Make relica output folder 
mkdir('relicaoutput'); 

% Launch eeglab
eeglab

% Load dataset wh_sub11_preproc.set
EEG = pop_loadset('wh_sub011_proc.set'); 

tic % Start timer
EEG = pop_relica(EEG,100,'runica','point', 'relicaoutput'); % Running RELICA
elapsedtime = toc; % Elapsed time since timer started

% Saving dataset
EEG = pop_saveset( EEG, 'filename','wh_sub011_proc_wrelica.set','filepath',pwd);

% Saving elapsed time and system info
info.system = system;
info.time = elapsedtime;
save('info.mat', 'info');



function EEG = eeg_oep_runica(filepath)

% Launch EEGLAB
% eeglab; % Not needed when eeg_oep_runica is a function

% Define file to load
filename = filepath;
% Load dataset in variable filename
EEG = pop_loadset(filename); 
% Decompose data into ICA using 'runica'
EEG = pop_runica(EEG, 'icatype', 'runica'); 

% Results
% Plot first 40 IC maps obtained in previous step
pop_topoplot(EEG, 0, [1:20] ,'EEG Data epochs',[4 5] ,0,'electrodes','on');
% Save figure
print('-djpeg', 'IC_scalp_maps.jpg');
% Save data with ICA decomposition
pop_saveset(EEG, 'filename', [EEG.filename]'wh_sub11_proc_output.set');  

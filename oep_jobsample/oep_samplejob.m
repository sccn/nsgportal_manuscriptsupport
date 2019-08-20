% Launch EEGLAB
eeglab; 
% Load dataset wh_sub11_preproc.set
EEG = pop_loadset('wh_sub011_proc.set'); 
% Decompose data into ICA using 'runica'
EEG = pop_runica(EEG, 'icatype', 'runica'); 

% Results
% Plot first 40 IC maps obtained in previous step
pop_topoplot(EEG, 0, [1:40] ,'EEG Data epochs',[8 5] ,0,'electrodes','on');
% Save figure
print('-djpeg', 'IC_scalp_maps.jpg');
% Save data with ICA decomposition
pop_saveset(EEG, 'filename', 'wh_sub11_proc_output.set'); 

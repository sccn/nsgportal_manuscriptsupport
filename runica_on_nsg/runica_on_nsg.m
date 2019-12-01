% Launch EEGLAB
eeglab; 
% Load the sample EEGLAB dataset
EEG = pop_loadset('wh_sub011_proc.set'); 
% Decompose the data into independent component (IC) processes
EEG = pop_runica(EEG, 'icatype', 'runica'); 

% Plot the scalp maps of the first (and largest) 20 ICs
pop_topoplot(EEG, 0, [1:20] ,'EEG Data epochs',[4 5] ,0,'electrodes','on');
% Save the figure as a JPEG file
print('-djpeg', 'IC_scalp_maps.jpg');
% Save the dataset, now including the ICA decomposition matrix
pop_saveset(EEG, 'filename', 'wh_sub11_proc_output.set'); 

% Optionally, delete the input dataset to reduce the output filesize
delete('wh_sub011_proc.set');
delete('wh_sub011_proc.fdt');
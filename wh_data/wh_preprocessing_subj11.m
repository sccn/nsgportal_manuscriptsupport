% Wakeman & Henson Data analysis: Preproccesing EEG data

% Authors: Ramon Martinez-Cancino, SCCN, 2019
%          Arnaud Delorme,         SCCN, 2019
%          
%
% Copyright (C) 2019  Ramon Martinez-Cancino,INC, SCCN
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
          
clear all; %
path2data = fullfile('/Volumes/ExtremeSSD/oep_manuscript_support/wh_data','whdata_subj11'); % Path to the files imported from the original data.
path2save = fullfile('/Volumes/ExtremeSSD/oep_manuscript_support/wh_data','whdata_subj11'); % Where to save EEGLAB files

dInfoS11; % load dataset information
[ALLEEG, EEG] = eeglab; % start EEGLAB
    
% Step 1: Load data previously imported
EEG = pop_loadset('filename', 'wh_sub011_run_1.set' , 'filepath', path2data);

% Step 2: Selecting only EEG channels for analysis (61-64 are not EEG)
EEG = pop_select(EEG, 'nochannel',61:64);

% Step 3: Downsampling data to 500 Hz
EEG = pop_resample(EEG, 250);

% Step 3: High-pass and notch filtering the data
EEG = pop_eegfiltnew(EEG, 1,   0,   1650, 0, [], 0);  % High pass at 1Hz
EEG = pop_eegfiltnew(EEG, 48,  52,  1650, 1, [], 0);  % Line noise suppression ~50Hz
EEG = pop_eegfiltnew(EEG, 98,  102, 1650, 1, [], 0);  % Line noise suppression ~100Hz

% Step 4: Apply Common Average Reference
EEG = pop_reref(EEG,[]);

% Step 5: Extract event-locked trials using events specified ([-1 2]sec relative to event).
EEG = pop_epoch( EEG, {'famous_new'    'famous_second_early'     'famous_second_late'...
                      'scrambled_new'  'scrambled_second_early'  'scrambled_second_late'...
                      'unfamiliar_new' 'unfamiliar_second_early' 'unfamiliar_second_late'}...
                      ,[-1  2], 'newname', 'Epoched', 'epochinfo', 'yes');

% Step 6: Perform baseline correction
EEG = pop_rmbase(EEG, [-1000 0]);

% Step 7: Clean data by rejecting epochs
% Epochs were rejected by performing visual inspection. 
% Epoch indices are saved in datInfoS11.bad_epochs
EEG = pop_select(EEG, 'notrial',datInfoS11.bad_epochs);

% Step 8: Save the dataset.
EEG = pop_saveset( EEG, 'filename', ['wh_' datInfoS11.name '_proc.set'], 'filepath', path2save);
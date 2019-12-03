% eeg_runica_nsg() - This is the same sample job used in the manuscript
%                    with some modification to turn it into a function. 
%                    The base functionalityremanins teh same by computing
%                    ICA decomposition in the data provided and generating
%                    a plot of the firts 20 component maps. Note for
%                    example that the firts lines has been commented out
%                    since this values are now provided as inputs to the
%                    function.
% Usage: 
%             >> EEG = eeg_runica_nsg(EEG, 'runica');
%
% Inputs:
%   EEG         - Input EEG dataset or array of datasets
%   icamethod   - {'runica', 'jader'} String with the ICA method to use
%
% Outputs:
%   EEG         - The input EEGLAB dataset with ICA decomposition performed 
%                 and stored in the fields icaweights and icasphere. 
%
%  See also: 
%
% Authors: Ramon Martinez-Cancino  SCCN/INC/UCSD 2019

% Copyright (C) Ramon Martinez-Cancino, 2019
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

function EEG = eeg_runica_nsg(EEG, icamethod)

% Launch EEGLAB
% eeglab; (Not needed when eeg_runica_nsg is a function)

% Define file to load (Not needed since EEG is provided as an input)
% filename = 'wh_sub011_proc.set';
% Load dataset in variable filename
% EEG = pop_loadset(filename); 

% Decompose data into ICA using the method definced in input icamethod.
EEG = pop_runica(EEG, 'icatype', icamethod); 

% Results
% Plot first 40 IC maps obtained in previous step
pop_topoplot(EEG, 0, [1:20] ,'EEG Data epochs',[4 5] ,0,'electrodes','on');
% Save figure
print('-djpeg', 'IC_scalp_maps.jpg');
% Save data with ICA decomposition
pop_saveset(EEG, 'filename', [EEG.filename(1:end-4) '_output.set']);  



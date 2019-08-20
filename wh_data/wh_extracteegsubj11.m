% Wakeman & Henson Data analysis Subject 11: Extract EEG data and import events and channel location

% Authors: Ramon Martinez-Cancino, SCCN, 2019
%          Arnaud Delorme, SCCN, 2019
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

% Paths below must be updated to the files on your enviroment.
clear;                                       % Clearing workspace
path2data = fullfile(pwd,'rawdata_subj11');  % Define path to  the original unzipped data files
path2save = fullfile(pwd,'whdata_subj11');   % Define to save EEGLAB files

dInfoS11; % load dataset information (datInfoS11)
[ALLEEG, EEG, CURRENTSET] = eeglab; % start EEGLAB

if ~exist('ft_read_data','file'), error('You must install the File-IO plugin'); end
    
% Extract EEG data from the FIF file and importing it to EEGLAB
ALLEEG = [];  % Initializing ALLEEG

for irun = 1:6 % Loop accross 6 runs
    
    % Step 1: Importing data with FileIO
    EEG = pop_fileio(fullfile(path2data, ['sub-11_ses-meg_meg_sub-11_ses-meg_task-facerecognition_run-0' num2str(irun) '_meg.fif']));
    
    % Step 2: Selecting EEG data and event (STI101) channels
    % EEG channels 1-60 are EEG, as are 65-70, but channels 61-64 are actually HEOG, VEOG and two floating channels (EKG).
    EEG = pop_select(EEG, 'channel', {'EEG001' 'EEG002' 'EEG003' 'EEG004' 'EEG005' 'EEG006' 'EEG007' 'EEG008' 'EEG009' 'EEG010' 'EEG011' 'EEG012' 'EEG013' 'EEG014' 'EEG015'...
        'EEG016' 'EEG017' 'EEG018' 'EEG019' 'EEG020' 'EEG021' 'EEG022' 'EEG023' 'EEG024' 'EEG025' 'EEG026' 'EEG027' 'EEG028' 'EEG029' 'EEG030'...
        'EEG031' 'EEG032' 'EEG033' 'EEG034' 'EEG035' 'EEG036' 'EEG037' 'EEG038' 'EEG039' 'EEG040' 'EEG041' 'EEG042' 'EEG043' 'EEG044' 'EEG045'...
        'EEG046' 'EEG047' 'EEG048' 'EEG049' 'EEG050' 'EEG051' 'EEG052' 'EEG053' 'EEG054' 'EEG055' 'EEG056' 'EEG057' 'EEG058' 'EEG059' 'EEG060'...
        'EEG061' 'EEG062' 'EEG063' 'EEG064' 'EEG065' 'EEG066' 'EEG067' 'EEG068' 'EEG069' 'EEG070' 'EEG071' 'EEG072' 'EEG073' 'EEG074' 'STI101'});
    
    % Step 3: Adding fiducials and rotating montage. Note:The channel location from this points were extracted from the FIF
    % files (see below) and written in the dInfo file. The reason is that File-IO does not import these coordinates.
    EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'LPA' [] [] datInfoS11.fid(1,1) datInfoS11.fid(1,2) datInfoS11.fid(1,3) [] [] [] 'FID' '' [] 0 [] []});
    EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'Nz'  [] [] datInfoS11.fid(2,1) datInfoS11.fid(2,2) datInfoS11.fid(2,3) [] [] [] 'FID' '' [] 0 [] []});
    EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'RPA' [] [] datInfoS11.fid(3,1) datInfoS11.fid(3,2) datInfoS11.fid(3,3) [] [] [] 'FID' '' [] 0 [] []});
    EEG = pop_chanedit(EEG,'nosedir','+Y');
    
    % Changing Channel types and removing channel locations for channels 61-64 (Raw data types are incorrect)
    EEG = pop_chanedit(EEG,'changefield',{61  'type' 'HEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
    EEG = pop_chanedit(EEG,'changefield',{62  'type' 'VEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
    EEG = pop_chanedit(EEG,'changefield',{63  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
    EEG = pop_chanedit(EEG,'changefield',{64  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
    
    % Recomputing head center
    EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');
    
    % Step 4: Re-import events from STI101 channel (the original ones are incorect)
    EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen',datInfoS11.edgelenval,'delevent','on','delchan','off','oper','double(bitand(int32(X),31))'); % first 5 bits
    
    % Step 5: Cleaning artefactual events (keep only valid event codes)
    EEG = pop_selectevent( EEG, 'type',[5 6 7 13 14 15 17 18 19] ,'deleteevents','on');
        
    % Step 6:Importing  button press info
    EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen',datInfoS11.edgelenval, 'delevent','off','oper','double(bitand(int32(X),8160))'); % bits 5 to 13
    
    % Step 7: Renaming button press events
    EEG = pop_selectevent( EEG, 'type',256, 'renametype',datInfoS11.event256 ,'deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',4096,'renametype',datInfoS11.event4096,'deleteevents','off');
    
    % Step 8: Rename face presentation events (information provided by authors)
    EEG = pop_selectevent( EEG, 'type',5,'renametype','famous_new','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',6,'renametype','famous_second_early','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',7,'renametype','famous_second_late','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',13,'renametype','unfamiliar_new','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',14,'renametype','unfamiliar_second_early','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',15,'renametype','unfamiliar_second_late','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',17,'renametype','scrambled_new','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',18,'renametype','scrambled_second_early','deleteevents','off');
    EEG = pop_selectevent( EEG, 'type',19,'renametype','scrambled_second_late','deleteevents','off');
    
    % Step 9: Correcting event latencies (events have a shift of 34 ms as per the authors)
    EEG = pop_adjustevents(EEG,'addms',34);
    
    % Replacing original imported channels
    % Note: This is a very unusual step that should not be done lightly. The reason here is because
    %       of the original channels were wrongly labeled at the time of the experiment
    EEG = pop_chanedit(EEG, 'rplurchanloc',1);
        
    % Step 10: Creating folder to save data if does not exist yet
    if ~exist(path2save, 'dir'), mkdir(path2save); end
    EEG = pop_saveset( EEG,'filename',['wh_' datInfoS11.name '_run_' num2str(irun) '.set'],'filepath',path2save);
    [ALLEEG, tmp, CURRENTSET] = eeg_store(ALLEEG, EEG); 
end

% Concatenate the six runs
EEG = pop_mergeset(ALLEEG, [1 2 3 4 5 6], 0);

% Save concatenated runs
pop_saveset(EEG, 'filename', ['wh_' datInfoS11.name '_allruns.set'], 'filepath', path2save);
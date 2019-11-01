% pop_oep_runica() - Run an ICA decomposition of an EEG dataset in NSG.
%                   This is an example of how to implement an EEGLAB 
%                   plug-in using HPC resources at NSG by means of the 
%                   plug-in nsgportal
% Usage: 
%             >> OUT_EEG = pop_oep_runica(EEG);   % Run ICA locally
%             >> OUT_EEG = pop_oep_runica(EEG,'local'); % Run ICA locally
%             >> OUT_EEG = pop_oep_runica(EEG,'nsg'); % Run ICA on NSG
%
% Inputs:
%   EEG         - input EEG dataset(structure) or NSG job ID (string)
%
% Optional inputs:
%   'compflag'  - {'local', 'nsg'}. String indicating if the computation must 
%                 be perfomed locally ('local') or in NSG ('nsg'). 
%                 Default:'local'
%
% Outputs:
%   OUT_EEG     - This can be either the EEGLAB dataset (structure) with the 
%                 results of the ICA decomposition, or a job ID (string) 
%                 correspoding  to the job ICA computation on NSG
%
%  See also: 
%
% Authors: Ramon Martinez-Cancino  SCCN/INC/UCSD 2019
%          Scott Makeig            SCCN/INC/UCSD 2019

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

function OUT_EEG = pop_oep_runica(EEG, compflag)

OUT_EEG  = [];

%% Section 1
%  Input block

if nargin < 3 || isstruct(EEG)
    % Beging GUI section
    if nargin < 2
        % GUI call
        if exist('EEG', 'var')
            datapath = fullfile(EEG.filepath, EEG.filename);
        else
            datapath = '';
        end
        compopt = {'NSG','Local computer'};
        cbload  =  '[filename pathname] = uigetfile(''*.set''); set(findobj(gcf,''tag'',''edit_datapath''),''string'',fullfile(pathname, filename));';
        
        promptstr    = { { 'style' 'text'       'string' 'Select dataset '}...
                         { 'style' 'edit'       'string' datapath    'tag' 'edit_datapath'} ...
                         { 'style' 'pushbutton' 'string' 'Browse...' 'callback' cbload }...
                         { 'style' 'text'       'string' 'Perform computation on'}...
                         { 'style' 'popupmenu'  'string' compopt }};
        ht = 3; wt = 3;
        geom = { {wt ht [0 0]        [1 1]}...
                 {wt ht [0 1]        [2 1]}...
                 {wt ht [2 1]        [1 1]}...
                 {wt ht [0 2]        [1 1]}...
                 {wt ht [1 2]        [1 1]}};
             
        guititle = 'Run ICA decomposition in NSG -- pop_operunica()';
        helpcom  = 'pophelp(''pop_oeprunica'')';
        result = inputgui( 'geom', geom, 'uilist', promptstr, 'helpcom', helpcom, 'title', guititle);
        
        if ~isempty(result{1})
            compflag = lower(compopt{result{2}});
            [filepath, filename, fileext] = fileparts(result{1});
            EEG = pop_loadset('filename',[filename fileext], 'filepath', filepath);
        else
            return;
        end
        % Ends GUI section
    end
    
    if compflag      
        %% Section 2
        %  Create temporary folder and save data and functions
        
        nsg_info; % get information on where to create the temporary file
        jobID = ['oeprunica_tmpjob' num2str(floor(rand(1)*1000))]; % Specified job ID (must be a string)
        
        % Create a temporary folder
        foldername = 'openrunicatmp'; % temporary folder name
        tmpJobPath = fullfile(outputfolder,'icansgtmp');
        if exist(tmpJobPath,'dir'), rmdir(tmpJobPath,'s'); end
        mkdir(tmpJobPath);
        
        % Save data in temporary folder previously created.
        % Here you may change the filename to match the one
        % in the script to be executed via NSG
        pop_saveset(EEG,'filename', EEG.filename, 'filepath', tmpJobPath);
        
        % Cpying plug-in function to execute into the job folder.
        % In some instances, a whole plug-in can be copied over.
        oeprunicafolder = mfilename('fullpath');
        oeprunicapath = fileparts(oeprunicafolder);
        copyfile(fullfile(oeprunicapath,'eeg_oep_runica.m'),tmpJobPath);
        
        %% Section 3
        %  Create script to be executed in NSG
        % Options defined by the user are written into the file
        
        % File writing begin ---
        fid = fopen( fullfile(tmpJobPath,'oe_prunica_job.m'), 'w');
        fprintf(fid, 'eeglab;\n');
        fprintf(fid, 'EEG = pop_loadset(''%s'');\n', EEG.filename);
        fprintf(fid, 'EEG = eeg_oep_runica(EEG);\n');
        fclose(fid);
        % File writing end ---
        
        %% Section 4
        %  Submit job to NSG. Time requested for computation is half an hour
        
        MAX_RUN_HOURS = 0.5;
        pop_nsg('run',tmpJobPath,'filename', 'oep_runica_job.m','jobid', jobID,'runtime', MAX_RUN_HOURS);
        OUT_EEG = jobID;
        
        display([char(10) 'oep_runica job (jobID:'  jobID ') has been submitted to NSG' char(10) ...
                          'Copy or keep in mind the jobID assigned to this job to retreive the results later on.' char(10)...
                          'You may follow the status as well as retreive the job ID of your job through pop_nsg' char(10)]);
        rmdir(tmpJobPath,'s');
        
    else
         %% Section 5
        % Local processing
        OUT_EEG = eeg_oeprunica(EEG);
    end
    
elseif ~isempty(nsg_findclientjoburl(EEG)) % Check if Job ID in EEG exist
    %% Section 6
    %  Download data
    pop_nsg('output',EEG);
    
    %% Section 7
    %  Delete job
    pop_nsg('delete',EEG);
    
else
    error('Invalid input provided to pop_oep_runica');
end
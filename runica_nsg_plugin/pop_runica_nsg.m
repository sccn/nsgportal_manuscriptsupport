% pop_runica_nsg() - Run an ICA decomposition of an EEG dataset in NSG.
%                    This is an example of how to implement an EEGLAB 
%                    plug-in using HPC resources at NSG by means of the 
%                    plug-in nsgportal
% Usage: 
%             >> OUT_EEG = pop_runica_nsg(EEG);                  % Run ICA locally
%             >> OUT_EEG = pop_runica_nsg(EEG,'local');          % Run ICA locally
%             >> OUT_EEG = pop_runica_nsg(EEG,'nsg');            % Run ICA on NSG
%             >> OUT_EEG = pop_runica_nsg(EEG,'nsg', 'runica');  % Run ICA on NSG using 'runica'
%             >> OUT_EEG = pop_runica_nsg('runicatmp_job');      % Retrieving runica_nsg computation 
%                                                                  with job ID 'runicatmp_job'
%
% Inputs:
%   EEG         - input EEG dataset(structure) or NSG job ID (string)
%
% Optional inputs:
%   'compflag'  - {'local', 'nsg'}. String indicating if the computation must 
%                 be perfomed locally ('local') or in NSG ('nsg'). 
%                 Default:'local'
%   'icamethod' - {'runica', 'jader'} ICA methods to use.
%
% Outputs:
%   EEG        - EEGLAB dataset (structure) with the results of the ICA 
%                decomposition. If the 'compflag' values is 'nsg' this
%                output will be same as the input provided, since the ICA
%                computation is done remotely in HPC resources.
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

function [EEG, jobID] = pop_runica_nsg(EEG, compflag, icamethod)
jobID  = [];

%% Section 1: Input block
if isstruct(EEG)
    % Beging GUI section
    if nargin < 3
        % GUI call
 
        icamethods = {'runica', 'jader'};
        compopt = {'NSG','Local computer'};
        
        promptstr    = { { 'style' 'text'       'string' 'Decompose current dataset using ICA'}...
                         { 'style' 'text'       'string' 'Select ICA method'}...
                         { 'style' 'popupmenu'  'string' icamethods 'tag' 'menu_icamethod'} ...
                         { 'style' 'text'       'string' 'Perform computation on'}...
                         { 'style' 'popupmenu'  'string' compopt 'tag' 'menu_compopt'}};
        ht = 3; wt = 2;
        geom = { {wt ht [0 0]        [2 1]}...
                 {wt ht [0 1]        [1 1]}...
                 {wt ht [1 1]        [1 1]}...
                 {wt ht [0 2]        [1 1]}...
                 {wt ht [1 2]        [1 1]}};
             
        guititle = 'Run ICA on NSG -- pop_runica_nsg()';
        helpcom  = 'pophelp(''pop_runica_nsg'')';
        result = inputgui( 'geom', geom, 'uilist', promptstr, 'helpcom', helpcom, 'title', guititle);
        if ~isempty(result)
            icamethod = icamethods{result{1}};
            compflag = lower(compopt{result{2}});
        else
            return
        end
    end
    
    % NSG
    if strcmp(compflag,'nsg')
        
        %% Section 2: Create temporary folder and save data and functions
        [tmpJobPath, jobID] = runicansg_savedata(EEG);
       
        %% Section 3: Create script to be executed in NSG      
         runicansg_createjobscript(EEG,icamethod, tmpJobPath);
            
        %% Section 4: Submit job to NSG. Time requested for computation is half an hour      
        MAX_RUN_HOURS = 0.5;
        pop_nsg('run',tmpJobPath,'filename', 'runica_nsg_job.m','jobid', jobID,'runtime', MAX_RUN_HOURS);
        
        display([char(10) 'runica_nsg job (jobID: '''  jobID ''') has been submitted to NSG' char(10) ...
                          'Copy or keep in mind the jobID assigned to this job to retreive the results later on.' char(10)...
                          'You may follow the status as well as retreive the job ID of your job through pop_nsg' char(10)]);
        rmdir(tmpJobPath,'s');
        return;
        
    % Local    
    else
         %% Section 5: Local processing         
        EEG = eeg_runica_nsg(EEG, icamethod);
    end
    
elseif ~isempty(nsg_findclientjoburl(EEG)) % Check if Job ID exist
    nsg_info; % get nsgportal plug-in settings
    jobID = EEG; EEG = [];
    
    %% Section 6: Download and load data   
    pop_nsg('output',jobID);
    
    %% Load the EEG structure with ICA computed
     load(fullfile(outputfolder,['nsgresults_' jobID],jobID, 'runicansg_input.mat'));
     EEG = pop_loadset('filepath',fullfile(outputfolder,['nsgresults_' jobID],jobID),'filename', [runicansg_input.filename(1:end-4) '_output.set']);
    
    %% Section 7: Delete NSG job    
    pop_nsg('delete',jobID);
    
else
    error('Invalid input provided. The fisrt input mus be eaither an EEG structure, or a valid job ID in your NSG account');
end

% Sub-function to save data
% -------------------------------------------------------------------------
function [tmpJobPath, jobID] = runicansg_savedata(EEG)

nsg_info; % get information on where to create the temporary file
jobID = ['runicansg_tmpjob' num2str(floor(rand(1)*10000))]; % Specified job ID (must be a string)

% Create a temporary folder
foldername = jobID; % We use the same as the job ID
tmpJobPath = fullfile(outputfolder,foldername);
if exist(tmpJobPath,'dir'), rmdir(tmpJobPath,'s'); end
mkdir(tmpJobPath);

% Save data in temporary folder previously created.
% Here you may change the filename to match the one
% in the script to be executed via NSG
pop_saveset(EEG,'filename', EEG.filename, 'filepath', tmpJobPath);

% Copying plug-in function to execute into the job folder.
% In some instances, a whole plug-in can be copied over.
runicansgfolder = mfilename('fullpath');
runicansgpath = fileparts(runicansgfolder);
copyfile(fullfile(runicansgpath,'eeg_runica_nsg.m'),tmpJobPath);

% Save structure with inputs for use after results retrieval
runicansg_input.filename = EEG.filename;
save(fullfile(tmpJobPath,'runicansg_input'),'runicansg_input');

% Sub-function to write and save job script
% -------------------------------------------------------------------------
function runicansg_createjobscript(EEG,icamethod, tmpJobPath)

fid = fopen( fullfile(tmpJobPath,'runica_nsg_job.m'), 'w');
fprintf(fid, 'eeglab;\n');
fprintf(fid, 'EEG = pop_loadset(''%s'');\n', EEG.filename);
fprintf(fid, 'EEG = eeg_runica_nsg(EEG, ''%s'');\n', icamethod);
fclose(fid);

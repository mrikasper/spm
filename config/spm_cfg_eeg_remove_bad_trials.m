function remove = spm_cfg_eeg_remove_bad_trials
% configuration file for removing bad trials
%__________________________________________________________________________
% Copyright (C) 2009-2021 Wellcome Trust Centre for Neuroimaging

% Vladimir Litvak
% $Id: spm_cfg_eeg_remove_bad_trials.m 8119 2021-07-06 13:51:43Z guillaume $


%--------------------------------------------------------------------------
% remove
%--------------------------------------------------------------------------
remove          = cfg_exbranch;
remove.tag      = 'remove';
remove.name     = 'Remove bad trials';
remove.val      = @remove_cfg;
remove.help     = {'Removes bad trials and re-orders trials to conform to condlist'}';
remove.prog     = @eeg_remove;
remove.vout     = @vout_eeg_remove;
remove.modality = {'EEG'};


%==========================================================================
function varargout = remove_cfg

persistent cfg
if ~isempty(cfg), varargout = {cfg}; return; end

%--------------------------------------------------------------------------
% D
%--------------------------------------------------------------------------
D        = cfg_files;
D.tag    = 'D';
D.name   = 'File Name';
D.filter = 'mat';
D.num    = [1 1];
D.help   = {'Select the M/EEG mat file.'};

%--------------------------------------------------------------------------
% prefix
%--------------------------------------------------------------------------
prefix         = cfg_entry;
prefix.tag     = 'prefix';
prefix.name    = 'Filename Prefix';
prefix.help    = {'Specify the string to be prepended to the filenames of the output dataset. Default prefix is ''r''.'};
prefix.strtype = 's';
prefix.num     = [1 Inf];
prefix.val     = {'r'};

[cfg,varargout{1}] = deal({D, prefix});


%==========================================================================
function out = eeg_remove(job)
% construct the S struct
S           = job;
S.D         = S.D{1};
out.D       = spm_eeg_remove_bad_trials(S);
out.Dfname  = {fullfile(out.D)};


%==========================================================================
function dep = vout_eeg_remove(job)
% return dependencies
dep(1)            = cfg_dep;
dep(1).sname      = 'Cleaned M/EEG data';
dep(1).src_output = substruct('.','D');
dep(1).tgt_spec   = cfg_findspec({{'strtype','e'}});

dep(2)            = cfg_dep;
dep(2).sname      = 'Cleaned M/EEG datafile';
dep(2).src_output = substruct('.','Dfname');
dep(2).tgt_spec   = cfg_findspec({{'filter','mat'}});

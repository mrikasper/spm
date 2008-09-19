function S = spm_cfg_eeg_filter
% configuration file for EEG Filtering
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Stefan Kiebel
% $Id: spm_cfg_eeg_filter.m 2126 2008-09-19 15:55:34Z stefan $

rev = '$Rev: 2126 $';
D = cfg_files;
D.tag = 'D';
D.name = 'File Name';
D.filter = 'mat';
D.num = [1 1];
D.help = {'Select the EEG mat file.'};

typ = cfg_menu;
typ.tag = 'type';
typ.name = 'Filter type';
typ.labels = {'Butterworth'};
typ.values = {'butterworth'};
typ.val = {'butterworth'};
typ.help = {'Select the filter type.'};

band = cfg_menu;
band.tag = 'band';
band.name = 'Filter band';
band.labels = {'lowpass', 'highpass', 'bandpass', 'stopband'};
band.values = {'low' 'high' 'bandpass' 'stop'};
band.val = {'low'};
band.help = {'Select the filter band.'};

PHz = cfg_entry;
PHz.tag = 'PHz';
PHz.name = 'Cutoff';
PHz.strtype = 'r';
PHz.num = [1 inf];
PHz.help = {'Enter the filter cutoff'};

flt = cfg_branch;
flt.tag = 'filter';
flt.name = 'Filter';
flt.val = {typ band PHz};

S = cfg_exbranch;
S.tag = 'eeg_filter';
S.name = 'M/EEG Filter';
S.val = {D flt};
S.help = {'Low-pass filters EEG/MEG epoched data.'};
S.prog = @eeg_filter;
S.vout = @vout_eeg_filter;
S.modality = {'EEG'};

function out = eeg_filter(job)
% construct the S struct
S.D = job.D{1};
S.filter = job.filter;

out.D = spm_eeg_filter(S);
out.Dfname = {out.D.fname};

function dep = vout_eeg_filter(job)
% Output is always in field "D", no matter how job is structured
dep = cfg_dep;
dep.sname = 'Filtered Data';
% reference field "D" from output
dep.src_output = substruct('.','D');
% this can be entered into any evaluated input
dep.tgt_spec   = cfg_findspec({{'strtype','e'}});

dep(2) = cfg_dep;
dep(2).sname = 'Filtered Datafile';
% reference field "Dfname" from output
dep(2).src_output = substruct('.','Dfname');
% this can be entered into any file selector
dep(2).tgt_spec   = cfg_findspec({{'filter','mat'}});

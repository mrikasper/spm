function spm_MEEGtools
% GUI gateway to MEEGtools toolbox
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Vladimir Litvak
% $Id: spm_MEEGtools.m 3566 2009-11-13 12:37:38Z vladimir $


funlist = {
    'Copy MEG sensors', 'spm_eeg_copygrad';
    'Re-reference EEG', 'spm_eeg_reref_eeg';
    'Fieldtrip interactive plotting', 'spm_eeg_plot_interactive';
    'Fieldtrip visual artefact rejection', 'spm_eeg_ft_artefact_visual';
    'Fieldtrip dipole fitting', 'spm_eeg_ft_dipolefitting';
    'Vector-AR connectivity measures', 'spm_eeg_var_measures';
    'Define spatial confounds' , 'spm_eeg_spatial_confounds'
    'Correct sensor data',        'spm_eeg_correct_sensor_data'
    'Use CTF head localization' , 'spm_eeg_megheadloc'
    'Fieldtrip manual coregistration' , 'spm_eeg_ft_datareg_manual'
    'Remove spikes from EEG' , 'spm_eeg_remove_spikes'
    'Reduce jumps in MEG data' , 'spm_eeg_remove_jumps'
    'Extract dipole waveforms', 'spm_eeg_dipole_waveforms'
    'Fieldtrip multitaper TF', 'spm_eeg_ft_multitaper_tf'
    'Fieldtrip-SPM robust multitaper coherence', 'spm_eeg_ft_multitaper_coherence'
    'Interpolate artefact segment', 'spm_eeg_interpolate_artefact'
    'FMRIB Detect ECG peaks',   'spm_eeg_fmrib_qrsdetect'     
    'Detect eyeblinks',  'spm_eeg_detect_eyeblinks'
    'Relabel trials for epoched CTF datasets', 'spm_eeg_recode_epoched_ctf'
    };

str = sprintf('%s|', funlist{:, 1});
str = str(1:(end-1));

fun = spm_input('MEEG tools',1,'m', str, strvcat(funlist(:, 2)));
  
eval(fun);
function [xy,label] = spm_eeg_project3D(sens, modality)
% Wrapper function to a fieldtrip function to project 3D locations 
% onto a 2D plane. 
% FORMAT [xy,label] = spm_eeg_project3D(sens, modality)
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Stefan Kiebel, Vladimir Litvak
% $Id: spm_eeg_project3D.m 8104 2021-05-18 14:45:42Z vladimir $

cfg = [];

cfg.showcallinfo = 'no';

switch modality
    case 'EEG'
        cfg.elec   = sens;
        cfg.rotate = 0;
    case 'MEG'
        cfg.grad   = sens;
    otherwise
        error('Unknown data type');
end

cfg.feedback = 'no'; 

try
    cfg.overlap = 'keep';
    lay = ft_prepare_layout(cfg);
catch
    cfg.overlap = 'shift';
    lay = ft_prepare_layout(cfg);
end

[sel1, sel2] = spm_match_str(sens.label, lay.label);

label =lay.label(sel2)';
xy = lay.pos(sel2, :);

nchan = size(xy, 1);

xy =(xy-repmat(min(xy), nchan, 1));
xy = xy./repmat(max(xy), nchan, 1);
xy = xy*0.9+0.05;
xy = xy';



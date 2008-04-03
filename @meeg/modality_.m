function res = modality(this)
% Returns data modality (like in SPM5)
% FORMAT this = modality(this)
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Vladimir Litvak
% $Id: modality_.m 1305 2008-04-03 17:39:04Z vladimir $

% Unlike in SPM5, in SPM8 modality is not well defined and is a property
% of channels rather than the whole file. So this function is only a
% temporary solution to make some pieces of code work.

if ~isempty(strmatch('MEG', chantypes(this), 'exact'))
    res = 'MEG';
elseif ~isempty(strmatch('EEG', chantypes(this), 'exact'))
    res = 'EEG';
elseif ~isempty(strmatch('LFP', chantypes(this), 'exact'))
    res = 'LFP';
else
    res = 'Other';
end

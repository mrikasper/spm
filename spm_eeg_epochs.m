function D = spm_eeg_epochs(S)
% function used for epoching continuous EEG/MEG data
% FORMAT D = spm_eeg_epochs(S)
% 
% S		    - optional input struct
% (optional) fields of S:
% D			- filename of EEG mat-file with continuous data
% events    - struct with various entries:
%    start     - samples to include before start of stimulus
%    stop	   - samples to include after start of stimulus
%    types	   - events to extract (vector of event types)
%    Inewlist  - switch (0/1) to have new list of event codes
%    Ec        - list of new event codes
%
% Output:
% D			- EEG data struct (also written to files)
%_______________________________________________________________________
%
% spm_eeg_epochs extracts single trials from continuous EEG/MEG data. The
% length of an epoch is determined by the samples before and after stimulus
% presentation. One can limit the extracted trials to specific trial types.
% Also, it is possible to re-number trial types, see above. 
% Note that epoching includes a baseline correction of each single trial,
% i.e. a subtraction of the average pre-stimulus average from all time
% points.
%_______________________________________________________________________
% @(#)spm_eeg_epochs.m	1.1 Stefan Kiebel 04/06/28

[Finter,Fgraph,CmdLine] = spm('FnUIsetup','EEG epoching setup',0);

try
    D = S.D;
catch
    D = spm_get(1, '.mat', 'Select EEG mat file');
end

P = spm_str_manip(D, 'H');

try
	D = spm_eeg_ldata(D);
catch    
	error(sprintf('Trouble reading file %s', D));
end

if ~isfield(D, 'events')
    D.events = [];
end
	
try 
    D.events.start = S.events.start;
catch
    D.events.start =...
        spm_input('Nr of samples before stimulus onset', '+1', 'i', '', 1);
end

try
    D.events.stop = S.events.stop;
catch
    D.events.stop = ...
        spm_input('Nr of samples after stimulus onset', '+1', 'i', '', 1);
end

try
    D.events.types = S.events.types;
catch
	disp(unique(D.events.code))
	D.events.types = ...
	 	spm_input('Event types to be epoched', '+1', 'i');
end

ind = find(ismember(D.events.code,D.events.types));

try
    Inewlist = S.events.Inewlist;
catch
    Inewlist = spm_input('Read new event list?', '+1', 'yes|no', [1 0]);
end

if Inewlist
    try
        Ec = S.events.Ec;
    catch    
        Ec = spm_input('Input event vector', '+1', 'w', [], length(ind));
    end
end

spm('Pointer', 'Watch'); drawnow;

D.fnamedat = ['e_' D.fnamedat];

D.datatype = 'int16';

fpd = fopen(fullfile(P, D.fnamedat), 'w');

% Allocate space for epoched data
D.Nsamples = D.events.stop + D.events.start+1;
d = zeros(D.Nchannels, D.Nsamples);

% Assemble epochs
k = 1;
D.scale.dim = [1 3];

D.scale.values = zeros(D.Nchannels, D.Nevents);

for i = 1:length(D.events.time)
	if any(D.events.code(i) == D.events.types)
        
        if	D.events.time(i) - D.events.start < 1 |...
                D.events.time(i) + D.events.stop > size(D.data, 2)
            % skip this trial
            warning(sprintf('%s: Event %d not extracted because not enough sample points', D.fname, i));
		else

   		    if Inewlist
			    D.events.code(i) = Ec(k); 
            end

            d = D.data(:, D.events.time(i) - D.events.start :...
					D.events.time(i) + D.events.stop, 1);
                
            % baseline subtraction
			d = d - ...
			repmat(mean(d(:,[1:abs(D.events.start)+1]),2), 1, D.Nsamples);
			
			D.scale.values(:, k) = max(abs(d'))./32767;
			d = int16(d./repmat(D.scale.values(:, k), 1, D.Nsamples));
			fwrite(fpd, d, 'int16');
						
			index(k) = i;
			k = k +1;
		end
	end
end

fclose(fpd);

D.events.types = unique(D.events.code(index));

D.data = [];
D.events.Ntypes = length(D.events.types);
D.events.code = D.events.code(index);
D.events.time = D.events.time(index);
D.Nevents = k-1;

% in case there is already some information about rejected trials
if ~isfield(D.events, 'reject')
    D.events.reject = zeros(1, D.Nevents);
end

D.datatype  = 'int16';

if Inewlist & D.Nevents ~= length(Ec)
	warning('Not all events in event list used!')
end

D.fname = ['e_' D.fname];
 
save(fullfile(P, D.fname), 'D');

spm('Pointer', 'Arrow');

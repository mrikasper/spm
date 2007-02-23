function DCM = spm_dcm_erp_data(DCM,ERP)
% prepares structures for forward model (both EEG and MEG)
% FORMAT DCM = spm_dcm_erp_data(DCM,ERP)
% DCM    -  DCM structure
% ERP    - 'ERP' or 'Induced' for evoked or induced response 
% requires
%
%    DCM.xY.Dfile
%    DCM.options.trials
%    DCM.options.Tdcm
%    DCM.options.D
%    
%
% sets
%    DCM.xY.Time    - Time [ms] of downsampled data
%    DCM.xY.dt      - sampling in seconds
%    DCM.xY.y       - concatenated response
%    DCM.xY.It      - Indices of time bins
%    DCM.xY.Ic      - Indices of good channels
%
%    DCM.xY.Hz      - Frequency bins (for Wavelet transform)
%    DCM.options.h
%__________________________________________________________________________
% Stefan Kiebel, Karl friston
% $Id: spm_dcm_erp_data.m 668 2006-10-26 16:35:28Z karl $

% Set defaults and Get D filename
%--------------------------------------------------------------------------
try
    ERP = strcmp(ERP,'ERP');
catch
    ERP = 1;
end

try
    Dfile = DCM.xY.Dfile;
catch
    errordlg('Please specify data and trials');
    error('')
end

% load D
%--------------------------------------------------------------------------
D = spm_eeg_ldata(Dfile);

% indices of EEG channel (excluding bad channels) and perstimulus times
%--------------------------------------------------------------------------
Ic              = setdiff(D.channels.eeg, D.channels.Bad);
Nc              = length(Ic);
DCM.M.dipfit.Ic = Ic;
DCM.xY.Ic       = Ic;
DCM.xY.Time     = 1000*[-D.events.start:D.events.stop]/D.Radc; % ms
DCM.xY.dt       = 1/D.Radc;

% options
%--------------------------------------------------------------------------
try
    DT   = DCM.options.D;
catch
    errordlg('Please specify down sampling');
    error('')
end
try
    trial = DCM.options.trials;
catch
    errordlg('please specify trials');
    error('')
end
try
    
    % time window and bins for modelling
    %----------------------------------------------------------------------
    T1      = DCM.options.Tdcm(1);
    T2      = DCM.options.Tdcm(2);
    [i, T1] = min(abs(DCM.xY.Time - T1));
    [i, T2] = min(abs(DCM.xY.Time - T2));
    
    % Time [ms] of downsampled data
    %----------------------------------------------------------------------
    It          = [T1:DT:T2]';
    Ns          = length(It);                % number of samples
    DCM.xY.Time = DCM.xY.Time(It);           % Down-sampled pst
    DCM.xY.dt   = DT/D.Radc;                 % sampling in seconds
    DCM.xY.It   = It;                        % Indices of time bins

catch
    errordlg('Please specify time window');
    error('')
end

% get Morelet wavelets if necessary
%--------------------------------------------------------------------------
if ~ERP
    
     DCM.xY.Nm  = 3;                        % number of frequnecy modes
     DCM.xY.Rft = 6;                        % wavelet coeficient
     DCM.xY.Hz  = 4:4:64;                   % Frequencies
     ST         = DCM.xY.dt*1000;           % sampling interval
     Nf         = length(DCM.xY.Hz);
     Y          = zeros(Nf,Ns,Nc);
     
     % high-pass filter
     %---------------------------------------------------------------------
     h     = 3;
     R     = spm_dctmtx(Ns,h);
     R     = speye(Ns) - R*inv(R'*R)*R';
     DCM.options.h = h;

     % create convolution matrices with reflecting boudnaries
     %---------------------------------------------------------------------
     M     = spm_eeg_morlet(DCM.xY.Rft, ST, DCM.xY.Hz, 32);
     for i = 1:Nf
         M{i}   = convmtx(M{i}',Ns);
         N      = fix((size(M{i},1) - Ns)/2);
         W      = M{i}([1:Ns] + N,:)*R;
         W      = diag(1./sqrt(sum(abs(W).^2,2)))*W;
         M{i}   = W;
     end
     
else
     Y  = zeros(Ns,Nc);
end

% if MEG, store grad struct in D.channels
%--------------------------------------------------------------------------
try
    DCM.xY.grad = D.channels.grad;
end

% get trial averages
%--------------------------------------------------------------------------
for i = 1:length(trial);
    if isfield(D.events,'reject')
        c = find(D.events.code == D.events.types(i) & ~D.events.reject);
    else
        c = find(D.events.code == D.events.types(i));
    end
    Nt    = length(c);

    % ERP
    %----------------------------------------------------------------------
    if ERP
        for j = 1:Nt
            Y = Y + squeeze(D.data(Ic,It,c(j)))';
        end
        
    % Wavelet amplitude
    %----------------------------------------------------------------------
    else
        spm_progress_bar('Init',Nf)
        fprintf('Wavelet transform')
        
        % Cycle over frequencies
        %------------------------------------------------------------------
        for k = 1:Nf
            y     = zeros(Ns,Nc);
            for j = 1:Nt
                y = y + abs(M{k}*D.data(Ic,It,c(j))');
            end
            Y(k, :, :) = y;
            spm_progress_bar('Set',k)
        end
        
        spm_progress_bar('Clear')
        fprintf(' - done\n')
    end
    DCM.xY.xy{i} = Y/Nt;
end

% concatenate response
%==========================================================================
if ERP
    DCM.xY.y    = spm_cat(DCM.xY.xy(:));
else
    
    % find frequency modes
    %----------------------------------------------------------------------
    for i = 1:length(DCM.xY.xy)
        Hz{i} = sum(DCM.xY.xy{i},3)';
    end
    Hz        = spm_cat(Hz{:});
    U         = spm_svd(spm_detrend(Hz)',0);
    U         = U(:,1:DCM.xY.Nm);
    
    % project time-frequnecy data onto modes
    %----------------------------------------------------------------------
    for i = 1:length(DCM.xY.xy)
        for j = 1:Nc
            Hc{j} = DCM.xY.xy{i}(:,:,j)'*U;
        end
        DCM.xY.xf(i,:) = spm_cell_swap(Hc)';
    end
    DCM.xY.y  = spm_cat(DCM.xY.xf);
    DCM.xY.U  = U;
end




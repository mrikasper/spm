function [D] = spm_eeg_inv_results(D)
% contrast of evoked responses and power for an MEG-EEG model
% FORMAT [D] = spm_eeg_inv_results(D)
% Requires:
%
%     D.inv{i}.contrast.woi   - time (ms) window of interest
%     D.inv{i}.contrast.fboi  - frequency window of interest
%
% this routine will create a contrast for each trial type and will compute
% induced repeonses in terms of power (over trials)
%__________________________________________________________________________

% SPM data structure
%==========================================================================
fprintf('\ncomputing contrast - please wait\n')
try
    model = D.inv{D.val};
catch
    
    model = D.inv{end};
end

% defaults
%--------------------------------------------------------------------------
try, woi = model.contrast.woi;  catch, woi = [80 120]; end
try, foi = model.contrast.fboi; catch, foi = 0;        end

% inversion parameters
%--------------------------------------------------------------------------
M    = model.inverse.M;                           % MAP projector
J    = model.inverse.J;                           % Trial average MAP estimate
V    = model.inverse.qV;                          % temporal correlations
T    = model.inverse.T;                           % temporal projector
U    = model.inverse.U;                           % spatial  projector
R    = model.inverse.R;                           % referencing matrix
Is   = model.inverse.Is;                          % Indices of ARD vertices
Ic   = model.inverse.Ic;                          % Indices of channels
It   = model.inverse.It;                          % Indices of time bins
pst  = model.inverse.pst;                         % preistimulus tim (ms)
Nd   = model.inverse.Nd;                          % number of mesh dipoles
Nt   = model.inverse.Nt;                          % number of trials per type
Nb   = size(T,1);                                 % number of time bins
Nc   = size(U,1);                                 % number of channels

% time-frequency contrast
%==========================================================================

% get [Gaussian] time window
%--------------------------------------------------------------------------
toi  = round(woi*(D.Radc/1000)) + D.events.start + 1;
fwhm = diff(toi);
t    = exp(-4*log(2)*([1:Nb] - mean(toi)).^2/(fwhm^2));
t    = t/sum(t);

% get frequency space and put PST subspace into contrast (W -> T*T'*W)
%--------------------------------------------------------------------------
if foi
    wt = 2*pi*[1:Nb]'/D.Radc;
    W  = [];
    for f = foi(1):foi(end)
        W = [W sin(f*wt) cos(f*wt)];
    end
    W  = diag(t)*W;
    W  = spm_svd(W,1);
else
    W  = t(:);
end
TW     = T'*W;
TTW    = T*TW;

% cycle over trial types
%==========================================================================
trial = model.inverse.trials;
for i = 1:length(Nt)

    % single-trial analysis (or single ERP) - JW
    %----------------------------------------------------------------------
    if Nt(i) == 1
        
        JW{i} = J{i}*TW(:,1);
        GW{i} = sum((J{i}*TW).^2,2);
        
    % multi-trial analysis (induced responses)  - GW
    %----------------------------------------------------------------------
    else
        
        % get projectors, inversion and data
        %==================================================================

        MUR   = M*U'*R;
        qC    = model.inverse.qC;
        QC    = qC*trace(TTW'*V*TTW);
        
        JW{i} = sparse(0);
        JWWJ  = sparse(0);
        c     = find(D.events.code == D.events.types(trial(i)));

        % conditional expectation of contrast (J*W) and its energy
        %------------------------------------------------------------------
        for j = 1:Nt(i)

            MYW   = MUR*squeeze(D.data(Ic,It,c(j)))*TTW/Nt(i);
            JW{i} = JW{i} + MYW(:,1);
            JWWJ  = JWWJ  + sum(MYW.^2,2);
        end
        
        % conditional expectation of total energy (source space GW)
        %------------------------------------------------------------------
        GW{i}   = JWWJ + QC/Nt(i);
        
        % conditional expectation of induced energy (source space IW)
        % NB: this is zero of Nt(i) = 1
        %--------------------------------------------------------------------------
        % IW   = GW - sum(JW.^2,2) - QC/(Nt(i)*Nt(i));

    end

end



% Save results
%==========================================================================
model.contrast.woi  = woi;
model.contrast.fboi = foi;

model.contrast.W    = W;
model.contrast.JW   = JW;
model.contrast.GW   = GW;

D.inv{D.val}        = model;


% Display
%==========================================================================
spm_eeg_inv_results_display(D);



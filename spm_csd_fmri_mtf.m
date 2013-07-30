function [y,w,S] = spm_csd_fmri_mtf(P,M,U)
% Spectral response of a DCM (transfer function x noise spectrum)
% FORMAT [y,w,s] = spm_csd_fmri_mtf(P,M,U)
%
% P - model parameters
% M - model structure
% U - model inputs (expects U.csd as complex cross spectra)
%
% y - y(nw,nn,nn} - cross-spectral density for nn nodes
%                 - for nw frequencies in M.Hz
% w - frequencies
% S - directed transfer functions (complex)
%
% This routine computes the spectral response of a network of regions
% driven by  endogenous fluctuations and exogenous (experimental) inputs.
% It returns the complex cross spectra of regional responses as a
% three-dimensional array. The endogenous innovations or fluctuations are
% parameterised in terms of a (scale free) power law, in frequency space.
%
% When the observer function M.g is specified, the CSD response is
% supplemented with observation noise in sensor space; otherwise the CSD
% is noiseless.
%
%
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_csd_fmri_mtf.m 5588 2013-07-21 20:59:39Z karl $


% compute log-spectral density
%==========================================================================

% frequencies of interest
%--------------------------------------------------------------------------
w    = M.Hz(:);
nw   = length(w);

% number of nodes and endogenous (neuronal) fluctuations
%--------------------------------------------------------------------------
nn   = M.l;
nu   = length(M.u);


% spectrum of neuronal fluctuations (Gu) and observation noise (Gn)
%==========================================================================

% experimental inputs
%--------------------------------------------------------------------------
Gu    = zeros(nw,nu,nu);
Gn    = zeros(nw,nn,nn);
if size(P.C,2)
    for i = 1:nu
        for j = 1:nu
            for k = 1:nw
                Gu(k,i,j) = P.C(i,:)*squeeze(U.csd(k,:,:))*P.C(j,:)';
            end
        end
    end
end

% neuronal fluctuations (Gu)
%--------------------------------------------------------------------------
for i = 1:nu
    Gu(:,i,i) = Gu(:,i,i) + exp(P.a(1,i) - 8)*w.^(-exp(P.a(2,i) - 1));
end

% observation noise (with global and specific components)
%--------------------------------------------------------------------------
for i = 1:nn
    for j = 1:nn
        Gn(:,i,j) = Gn(:,i,j) + exp(P.b(1,1) - 4)*w.^(-exp(P.b(2,1) - 2));
    end
    Gn(:,i,i) = Gn(:,i,i) + exp(P.c(1,i) - 2)*w.^(-exp(P.c(2,i) - 2));
end


% transfer functions (FFT of first-order Volterra kernel)
%==========================================================================
P.C   = speye(nn,nu);
S     = spm_dcm_mtf(P,M);

% predicted cross-spectral density
%--------------------------------------------------------------------------
G     = zeros(nw,nn,nn);
for i = 1:nn
    for j = 1:nn
        for k = 1:nu
            for l = 1:nu
                G(:,i,j) = G(:,i,j) + S(:,i,k).*Gu(:,k,l).*conj(S(:,j,l));
            end
        end
    end
end

% and  channel noise
%--------------------------------------------------------------------------
if isfield(M,'g')
    y = G + Gn;
else
    y = G;
end
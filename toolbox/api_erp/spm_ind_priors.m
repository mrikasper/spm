function [varargout] = spm_ind_priors(A,B,C,dipfit,Nu,Nf)
% prior moments for a neural-mass model of erps
% FORMAT [pE,gE,pC,gC] = spm_ind_priors(A,B,C,dipfit,Nu,Nf)
% A{2},B{m},C  - binary constraints on extrinsic connections
% dipfit       - prior forward model structure
% Nu           - number of input components
% Nf           - number of frequencies

%
% pE - prior expectation - f(x,u,P,M)
% gE - prior expectation - g(x,u,G,M)
%
% spatial parameters
%--------------------------------------------------------------------------
%    gE.Lpos - position                   - ECD
%    gE.Lmon - moment (orientation)       - ECD
%
% or gE.L    - coeficients of local modes - Imaging
%
% connectivity parameters
%--------------------------------------------------------------------------
%    pE.A    - trial-invariant
%    pE.B{m} - trial-dependent
%    pE.C    - stimulus-stimulus dependent
%
%    p.K     - global rate [coupling] constant
%
% stimulus and noise parameters
%--------------------------------------------------------------------------
%    pE.R - magnitude, onset and dispersion
%    pE.N - background fluctuations
%
% pC - prior covariances: cov(spm_vec(pE))
%__________________________________________________________________________
%
% David O, Friston KJ (2003) A neural mass model for MEG/EEG: coupling and
% neuronal dynamics. NeuroImage 20: 1743-1755
%__________________________________________________________________________
% %W% Karl Friston %E%

% defaults
%--------------------------------------------------------------------------
if nargin < 4, dipfit.type = 'LFP'; end
if nargin < 5, Nu = 1;              end
if nargin < 6, Nf = 3;              end


% disable log zero warning
%--------------------------------------------------------------------------
warning off
n     = size(C,1);                                 % number of sources
n1    = ones(n,1);

% paramters for electromagnetic forward model
%--------------------------------------------------------------------------
switch dipfit.type
    
    case{'ECD (EEG)','ECD (MEG)'}
    %----------------------------------------------------------------------
    G.Lpos = dipfit.L.pos;  U.Lpos =   0*ones(3,n);    % dipole positions
    G.Lmom = G.Lpos/32;     U.Lmom =   2*ones(3,n);    % dipole orientations

    case{'Imaging'}
    %----------------------------------------------------------------------
    m      = dipfit.Nm;
    G.L    = ones(m,n)/16;  U.Lpos =  16*ones(m,n);    % dipole modes
    
end

% Global scaling
%--------------------------------------------------------------------------
E.K  = 0;
V.K  = 1/8;

% set extrinsic connectivity - linear and noninlear (cross frequency)
%--------------------------------------------------------------------------
E.A  = kron(speye(Nf,Nf),A{1}/4 - speye(n,n));
V.A  = kron(speye(Nf,Nf),A{1}) + kron(1 - speye(Nf,Nf),A{2});;

% input-dependent
%--------------------------------------------------------------------------
for i = 1:length(B)
    E.B{i} = sparse(n*Nf,n*Nf);
    V.B{1} = kron(ones(Nf,Nf),B{i});
end

% exognenous inputs
%--------------------------------------------------------------------------
E.C  = kron(1./[1:Nf]',C);
V.C  = E.C > 0;

% set stimulus parameters: magnitude, onset and dispersion
%--------------------------------------------------------------------------
E.R  = ones(Nu,1)*[1 0 1];
V.R  = ones(Nu,1)*[1 1/16 1/16];

% background fluctuations: amplitude and Hz
%--------------------------------------------------------------------------
E.N  = [0 0 10];
V.N  = [1 1 1];


% prior momments
%--------------------------------------------------------------------------
varargout{1} = E;
varargout{2} = G;
varargout{3} = diag(sparse(spm_vec(V)));
varargout{4} = diag(sparse(spm_vec(U)));
warning on
  

function varargout = spm_shoot3d(v0,prm,args)
% Geodesic shooting
% FORMAT [phi,Jphi,v1,theta,Jtheta] = spm_shoot3d(v0,prm,args)
% v0   - Initial velocity field n1*n2*n3*3 (single prec. float)
% prm  - Differential operator parameters
% prm  - 7 parameters (settings)
%        - [1] Regularisation type (ie the form of the differential
%          operator), can take values of
%           - 0 Linear elasticity
%           - 1 Membrane energy
%           - 2 Bending energy
%        - [2][3][4] Voxel sizes
%        - [5][6][7] Regularisation parameters
%           - For "membrane energy", the parameters are
%             lambda, unused and id.
%           - For "linear elasticity", the parameters are
%             mu, lambda, and id
%           - For "bending energy", the parameters are
%             lambda, id1 and id2.
% args - Integration parameters
%        - [1] Num time steps
%        - [2][3] Multigrid parameters (cycles and iterations)
%          for generating velocities from momentum
%
% phi  - Forward deformation field n1*n2*n3*3 (single prec. float)
% Jphi - Forward Jacobian tensors n1*n2*n3 (single prec. float)
% v1   - Final velocity field n1*n2*n3*3 (single prec. float)
% theta - Inverse deformation field n1*n2*n3*3 (single prec. float)
% Jtheta   - Inverse Jacobian tensors n1*n2*n3 (single prec. float)
%
% This code generates deformations and their Jacobian determinans from
% initial velocity fields by gedesic shooting.  See the work of Miller,
% Younes and others.
%
% LDDMM (Beg et al) uses the following evolution equation:
%     d\phi/dt = v_t(\phi_t)
% where a variational procedure is used to find the stationary solution
% for the time varying velocity field.
% In principle though, once the initial velocity is known, then the
% velocity at subsequent time points can be computed.  This requires
% initial momentum (m_0), computed (using differential operator L) by:
%     m_0 = L v_0
% Then (Ad_{\phi_t})^* m_0 is computed:
%     m_t = |d \phi_t| (d\phi_t)^T m_0(\phi_t)
% The velocity field at this time point is then obtained by using
% multigrid to solve:
%     v_t = L^{-1} m_t
%
% These equations can be found in:
% Younes (2007). "Jacobi fields in groups of diffeomorphisms and
% applications". Quarterly of Applied Mathematics, vol LXV,
% number 1, pages 113-134 (2007).
%
% Note that in practice, (Ad_{\phi_t})^* m_0 is computed differently,
% by multiplying the initial momentum by the inverse of the Jacobian
% matrices of the inverse warp, and pushing the values to their new
% location by the inverse warp (see the "pushg" code of dartel3).
% Multigrid is currently used to obtain v_t = L^{-1} m_t, but
% this could also be done by convolution with the Greens function
% K = L^{-1} (see e.g. Bro-Nielson).
%
%________________________________________________________
% (c) Wellcome Trust Centre for NeuroImaging (2009)

% John Ashburner
% $Id$

args0 = [8 4 4];
if nargin<3,
    args = args0;
else
    if numel(args)<numel(args0),
        args = [args args0((numel(args)+1):end)];
    end
end
verb     = false;
N        = args(1);   % # Time steps
fmg_args = args(2:3); % Multigrid params
d        = size(v0);
d        = d(1:3);
vt       = v0;

if ~isfinite(N),
    % Number of time steps from an educated guess about how far to move
    N = double(floor(sqrt(max(max(max(v0(:,:,:,1).^2+v0(:,:,:,2).^2+v0(:,:,:,3).^2)))))+1);
end

if verb, fprintf('N=%g:', N); end

m0       = dartel3('vel2mom',v0,prm); % Initial momentum (m_0 = L v_0)
if verb, fprintf('\t%g', 0.5*sum(v0(:).*m0(:))/prod(d)); end

% Compute initial small deformation and Jacobian matrices from the velocity.
% The overall deformation and its Jacobian tensor field is generated by
% composing a series of small deformations.
[ phi, Jphi]     = dartel3('smalldef', vt,1/N);

% If required, also compute the forward and possibly also its Jacobian
% tensor field. Note that the order of the compositions will be the
% reverse of those for building the forward deformation.
if nargout>=5,
    [theta,Jtheta] = dartel3('smalldef', vt,-1/N);
elseif nargout>=4,
    theta          = dartel3('smalldef', vt,-1/N);
end

for t=2:abs(N),
    mt             = dartel3('pushg',m0,phi,Jphi);
    vt             = mom2vel(mt,prm,fmg_args,vt);
    if verb, fprintf('\t%g', 0.5*sum(vt(:).*mt(:))/prod(d)); end

    [  dp,   dJ]   = dartel3('smalldef',  vt,1/N);       % Small deformation
    [ phi, Jphi]   = dartel3('comp', dp, phi, dJ, Jphi); % Build up large def. from small defs

    clear dp dJ

    % If required, build up forward deformation and its Jacobian tensor field from
    % small deformations
    if nargout>=5,
        [   dp,    dJ] = dartel3('smalldef',  vt,-1/N);    % Small deformation
        [theta,Jtheta] = dartel3('comp', theta,dp, Jtheta,dJ);  % Build up large def. from small defs
        clear dp dJ
    elseif nargout>=4,
        dp             = dartel3('smalldef',  vt,-1/N);    % Small deformation
        theta          = dartel3('comp', theta, dp);       % Build up large def. from small defs
        clear dp
    end
    drawnow
end
if verb, fprintf('\n'); end


varargout{1} = phi;
varargout{2} = Jphi;
if nargout>=3,
    mt           = dartel3('pushg',m0,phi,Jphi);
    varargout{3} = mom2vel(mt,prm,fmg_args,vt);
end
if nargout>=4, varargout{4} = theta; end
if nargout>=5, varargout{5} = Jtheta;   end
%__________________________________________________________________________________

%__________________________________________________________________________________
function vt = mom2vel(mt,prm,fmg_args,vt)
% L^{-1} m_t

r   = dartel3('vel2mom',vt,prm);
if prm(1) == 0,
    % This option has been coded up in C
    vt = dartel3('mom2vel', mt-r, [prm fmg_args])+vt;
else
    % This option has not been coded in C yet, so needs to be
    % done in a less efficient way
    dm = size(mt);
    H  = zeros([dm(1:3),6],'single');
    vt = dartel3('fmg',H,mt-r, [prm fmg_args])+vt;
end

if false,
    % Go for machine precision
    r  = dartel3('vel2mom',vt,prm);
    ss = sum(sum(sum(sum((mt-r).^2))));
    for i=1:8,
        oss = ss;
        vt  = dartel3('mom2vel', mt-r, [prm fmg_args])+vt;
        r   = dartel3('vel2mom',vt,prm);
        ss  = sum(sum(sum(sum((mt-r).^2))));
        if ss/oss>0.9, break; end
    end
end
%__________________________________________________________________________________

%__________________________________________________________________________________


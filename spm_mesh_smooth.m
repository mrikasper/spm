function T = spm_mesh_smooth(M, T, S)
% Perform Gaussian smoothing on data lying on a surface mesh
% FORMAT K = spm_mesh_smooth(M)
% M        - patch structure
% K        - smoothing kernel (based on graph Laplacian)
%
% FORMAT T = spm_mesh_smooth(M, T, S)
% FORMAT T = spm_mesh_smooth(K, T, S)
% T        - [vx1] data vector
% S        - smoothing parameter (number of iterations)
%__________________________________________________________________________
% Copyright (C) 2010-2020 Wellcome Centre for Human Neuroimaging

% Karl Friston, Guillaume Flandin
% $Id: spm_mesh_smooth.m 7890 2020-07-06 17:26:06Z guillaume $


if isstruct(M) || numel(M) == 1
    A = spm_mesh_distmtx(M,0);
    N = size(A,1);
    K = speye(N,N) + (A - spdiags(sum(A,2),0,N,N)) / 16;
else
    K = M;
end

if nargin == 1, T = K; return; end

for i=1:S
    T = K * T;
end

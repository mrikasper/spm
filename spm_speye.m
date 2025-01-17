function [D] = spm_speye(m,n,k,c)
% sparse leading diagonal matrix
% FORMAT [D] = spm_speye(m,n,k,c)
%
% returns an m x n matrix with ones along the k-th leading diagonal. If
% call with an optional fourth argument c = 1, a wraparound sparse matrix
% is returned. If c = 2, then empty rows or columns are filled in on the
% leading diagonal
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_speye.m 8172 2021-10-25 10:20:42Z karl $


% default k = 0
%--------------------------------------------------------------------------
if nargin < 4, c = 0; end
if nargin < 3, k = 0; end
if nargin < 2, n = m; end
 
% leading diagonal matrix
%--------------------------------------------------------------------------
D = spdiags(ones(m,1),k,m,n);

% add wraparound if necessary
%--------------------------------------------------------------------------
if c == 1
    if k < 0
        D = D + spm_speye(m,n,min(n,m) + k);
    elseif k > 0
        D = D + spm_speye(m,n,k - min(n,m));
    end
elseif c == 2
    i = find(~any(D));
    D = D + sparse(i,i,1,n,m);
    
end

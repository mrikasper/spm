function [X] = spm_dot(X,x,i)
% Multidimensional dot (inner) product
% FORMAT [Y] = spm_dot(X,x,[DIM])
%
% X   - numeric array
% x   - cell array of numeric vectors
% DIM - dimensions to omit (assumes ndims(X) = numel(x))
%
% Y  - inner product obtained by summing the products of X and x along DIM
%
% If DIM is not specified the leading dimensions of X are omitted.
% If x is a vector the inner product is over the first matching dimension of X
%
% See also: spm_cross
%__________________________________________________________________________
% Copyright (C) 2015 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_dot.m 8183 2021-11-04 15:25:19Z guillaume $

% initialise dimensions
%--------------------------------------------------------------------------
if iscell(x)
    DIM = (1:numel(x)) + ndims(X) - numel(x);
else
    DIM = find(size(X) == numel(x),1);
    x   = {x};
end

% omit dimensions specified
%--------------------------------------------------------------------------
if nargin > 2
    DIM(i) = [];
    x(i)   = [];
end

% inner product using recursive summation (and bsxfun)
%--------------------------------------------------------------------------
for d = 1:numel(x)
    s         = ones(1,ndims(X));
    s(DIM(d)) = numel(x{d});
    X         = bsxfun(@times,X,reshape(full(x{d}),s));
    X         = sum(X,DIM(d));
end

% eliminate singleton dimensions
%--------------------------------------------------------------------------
X = squeeze(X);

return

% NB: alternative scheme using outer product
%==========================================================================

% outer product and sum
%--------------------------------------------------------------------------
x      = spm_cross(x);
s      = ones(1,ndims(X));
S      = size(X);
s(DIM) = S(DIM);
x      = reshape(full(x),s);
X      = bsxfun(@times,X,x);
for d  = 1:numel(DIM)
    X  = sum(X,DIM(d));
end
X      = squeeze(X);

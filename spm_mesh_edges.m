function [E,L] = spm_mesh_edges(M)
% Return edges of a surface mesh
% FORMAT [E,L] = spm_mesh_edges(M)
% M        - a [nx3] faces array or a patch handle/structure
%
% E        - a [mx2] edges array 
% L        - a [m,1] edge length vector
%__________________________________________________________________________
% Copyright (C) 2010-2021 Wellcome Centre for Human Neuroimaging

% Guillaume Flandin
% $Id: spm_mesh_edges.m 8083 2021-03-18 18:52:59Z guillaume $


%-Parse input arguments
%--------------------------------------------------------------------------
if ishandle(M)
    F = get(M,'Faces');
elseif ~isnumeric(M)
    F = M.faces;
end

%-Compute edges
%--------------------------------------------------------------------------
F = sort(F,2);
E = unique([F(:,[1 2]);F(:,[2 3]);F(:,[1 3])],'rows');

%-Compute edge distances
%--------------------------------------------------------------------------
if nargout > 1
    L = M.vertices(E',:);
    L = permute(reshape(L',3,2,[]),[2 1 3]);
    L = squeeze(sqrt(sum((L(1,:,:) - L(2,:,:)).^2,2)));
end

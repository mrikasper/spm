
% surface render a memory mapped 8 bit image
% FORMAT [REN, ZBUF, X, Y, Z] = spm_render_vol(V, A, [i j], [u n])
% V       -  is the memory mapped volume
% A       -  {4 x 4} affine transformation matrix
% [i j]   -  dimensions of REN
% [u n]   -  u is threhsold at which voxels are 'solid'
%            n is the number of nearest neighbours to use to determine the
%            surface orientation
% REN     -  is the rendered image
% ZBUF    -  distance from the view plane to the object's surface
% X, Y, Z -  are images containing the coordinates of the voxels on the
%            surface of the volume.
%____________________________________________________________________________
%
% [i j] defines the two dimensions of the output image. The coordinates in
% 3-D space of the voxels in this image are assumed to range from 1,1,0 to
% i,j,0.
%
% For each pixel in the volume, the coordinates (x,y,z & 1) are multiplied
% by the matrix A, to give the image coordinates that these voxels map to
%
% The threshold at which voxels are assumed to be solid pertains to the
% 8-bit data i.e. {0 - 255}
%
% Illumination is assumed to be from the viewplane
%
%__________________________________________________________________________
% %W% %E%

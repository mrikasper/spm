function opts = spm_config_display
% Configuration file for display jobs
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id$


%_______________________________________________________________________

data.type = 'files';
data.name = 'Image to Display';
data.tag  = 'data';
data.filter = 'image';
data.num  = 1;
data.help = {'Image to display.'};

opts.type = 'branch';
opts.name = 'Display Image';
opts.tag  = 'disp';
opts.val  = {data};
opts.prog = @dispim;
p1 = [...
'This is an interactive facility that allows orthogonal sections'...
' from an image volume to be displayed.  Clicking the cursor on either'...
' of the three images moves the point around which the orthogonal'...
' sections are viewed.  The co-ordinates of the cursor are shown both'...
' in voxel co-ordinates and millimeters within some fixed framework.'...
' The intensity at that point in the image (sampled using the current'...
' interpolation scheme) is also given. The position of the crosshairs'...
' can also be moved by specifying the co-ordinates in millimeters to'...
' which they should be moved.  Clicking on the horizontal bar above'...
' these boxes will move the cursor back to the origin  (analogous to'...
' setting the crosshair position (in mm) to [0 0 0]).'];
p2 =  [...
'The images can be re-oriented by entering appropriate translations,'...
' rotations and zooms into the panel on the left.  The transformations'...
' can then be saved by hitting the "Reorient images..." button.  The'...
' transformations that were applied to the image are saved to the'...
' header information of the selected images.  The transformations are'...
' considered to be relative to any existing transformations that may be'...
' stored.  Note that the order that the'...
' transformations are applied in is the same as in spm_matrix.m.'];
p3 = [...
'The "Reset..." button next to it is for setting the orientation of'...
' images back to transverse.  It retains the current voxel sizes,'...
' but sets the origin of the images to be the centre of the volumes'...
' and all rotations back to zero.'];
p4 = [...
'The right panel shows miscellaneous information about the image.'...
' This includes:'];
p5 = [...
'There are also a few options for different resampling modes, zooms'...
' etc.  You can also flip between voxel space (as would be displayed'...
' by Analyze) or world space (the orientation that SPM considers the'...
' image to be in).  If you are re-orienting the images, make sure that'...
' world space is specified.  Blobs (from activation studies) can be'...
' superimposed on the images and the intensity windowing can also be'...
' changed.'];

p6 = ['If you have put your images in the correct file format, ',...
      'then (possibly after specifying some rigid-body rotations):'];
p7 = ['    The top-left image is coronal with the top (superior) ',...
      'of the head displayed at the top and the left shown on the left. ',...
      'This is as if the subject is viewed from behind.'];
p8 = ['    The bottom-left image is axial with the front (anterior) of the ',...
      'head at the top and the left shown on the left. ',...
      'This is as if the subject is viewed from above.'];
p9 = ['    The top-right image is sagittal with the front (anterior) of ',...
      'the head at the left and the top of the head shown at the top. ',...
      'This is as if the subject is viewed from the left.'];

opts.help = {p1,'',p2,'',p3,'',p4,...
'   Dimensions - the x, y and z dimensions of the image.',...
'   Datatype   - the computer representation of each voxel.',...
'   Intensity  - scalefactors and possibly a DC offset.',...
'   Miscellaneous other information about the image.',[...
'   Vox size   - the distance (in mm) between the centres of ',...
'                neighbouring voxels.'],...
'   Origin     - the voxel at the origin of the co-ordinate system',[...
'   DIr Cos    - Direction cosines.  This is a widely used',...
'                representation of the orientation of an image.'],...
'',p5,'','',p6,p7,p8,p9};

%------------------------------------------------------------------------

%------------------------------------------------------------------------
function dispim(varargin)
job = varargin{1};
spm_image('init',job.data{1});
return;

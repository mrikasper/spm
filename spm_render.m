function spm_render(XYZ,t,V)
% Render blobs on surface of a 'standard' brain
% FORMAT spm_render
%_______________________________________________________________________
% 
% FORMAT spm_render(XYZ,t,V)
% XYZ - the x, y & z coordinated of the transformed t values.
% t   - the transformed t values
% V   - a vector containing the voxel sizes in positions 5-7.
%_______________________________________________________________________
% 
% spm_render prompts for details of a SPM{Z} that is then displayed
% superimposed on the surface of a standard brain.
% The blobs which are displayed are the integral of all transformed t
% values which are less than 3cm deep.


% %W% John Ashburner FIL %E%


if (nargin==0)

	spm_figure('Clear','Interactive');
	spm_figure('Clear','Graphics');
	Finter = spm_figure('FindWin','Interactive');
	set(Finter,'Name','SPM render')
	global CWD

	% Which SPM
	%-----------------------------------------------------------------------
	SPMZ     = spm_input('which SPM',1,'b','SPM{Z}|SPM{F}',[1 0]);
	SPMF     = ~SPMZ;

	% Get thresholded data, thresholds and parameters
	%-----------------------------------------------------------------------
	if SPMZ
		[t,XYZ,QQ,U,k,s,w] = spm_projections_ui('Results');
	elseif SPMF
		[t,XYZ,QQ,U,k,s,w] = spm_projectionsF_ui('Results');

	end

	% get voxel sizes (in 'V') from mat file
	%-----------------------------------------------------------------------
	load([CWD '/SPM.mat']);

	spm_render(XYZ,t,V);

	return;
end



% Perform the rendering
%_______________________________________________________________________

set(spm_figure('FindWin','Interactive'),'Name','executing','Pointer','watch');


if (nargin<3)
	V = [0 0 0 2 2 2];
end

load render

mx = 0;

% field should be sampled every mm.
%---------------------------------------------------------------------------
t1       = [];
XYZ1     = [];
xx       = XYZ(1,:);
for x1=(-V(4)/2):(V(4)/2-eps*20)
	XYZ(1,:) = xx+x1;
	XYZ1 = [XYZ1 XYZ];
	t1   = [t1 t];
end

t0        = [];
yy        = XYZ1(2,:);
XYZ       = [];
for y1=(-V(5)/2):(V(5)/2-eps*20)
	XYZ1(2,:) = yy+y1;
	XYZ       = [XYZ XYZ1];
	t0        = [t0 t1];
end

t        = [];
XYZ1     = [];
zz       = XYZ(3,:);
for z1=(-V(6)/2):(V(6)/2-eps*20)
	XYZ(3,:)  = zz+z1;
	XYZ1      = [XYZ1 XYZ];
	t         = [t t0];
end


spm_progress_bar('Init', 8, 'Making pictures', 'Number completed');

for i=1:size(Matrixes,1)
	eval(['MM = ' Matrixes(i,:) ...
		'; ren = ' Rens(i,:) '; dep = ' Depths(i,:) ';']);



	% transform from Taliarach space to space of the rendered image
	%---------------------------------------------------------------------------
	xyz      = (MM(1:3,1:3)*XYZ1);
	xyz(1,:) = xyz(1,:) + MM(1,4);
	xyz(2,:) = xyz(2,:) + MM(2,4);
	xyz(3,:) = xyz(3,:) + MM(3,4);
	xyz      = round(xyz);



	% only use values which will fit on the image
	%---------------------------------------------------------------------------
	msk = find((xyz(1,:) >= 1) & (xyz(1,:) <= size(dep,1)) ...
		&  (xyz(2,:) >= 1) & (xyz(2,:) <= size(dep,2)));
	xyz      = xyz(:,msk);
	t0       = t(msk);

	X = zeros(size(dep));

	if ~isempty(xyz)

		% calculate 'depth' of values, and ignore any which are more than 30 mm
		% behind the surface.
		%---------------------------------------------------------------------------
		z1  = dep(xyz(1,:)+(xyz(2,:)-1)*size(dep,1));
		msk = find(xyz(3,:) < (z1+20) & xyz(3,:) > (z1-5));
		xyz = xyz(:,msk);
		t0  = t0(msk);

		% generate an image of the integral of the blob values.
		%---------------------------------------------------------------------------
		if ~isempty(xyz)
			X = full(sparse(xyz(1,:), xyz(2,:), t0, size(dep,1), size(dep,2)));
		end
	end

	mx = max([mx max(max(X))]);
	eval(['X' num2str(i) ' = X;']);
	spm_progress_bar('Set', i);
end

spm_progress_bar('Clear');
figure(spm_figure('FindWin','Graphics'));
spm_figure('Clear','Graphics');
load Split
colormap(split);

% Combine the brain surface renderings with the blobs, and display.
%---------------------------------------------------------------------------
for i=1:size(Matrixes,1)
	eval(['ren = ' Rens(i,:) '; X = X' num2str(i) ';']);
	msk = find(X ~= 0);
	ren(msk) = X(msk)*(64/(mx))+64;
	subplot(4,2,i);
	image(ren);
	axis image off xy
end

spm_figure('Clear','Interactive');


function spm_smooth_ui
% Smoothing or convolving
%___________________________________________________________________________
%
% Convolves image files with an isotropic (in real space) Gaussian kernel 
% of a specified width.
%
% Uses:
%
% As a preprocessing step to suppress noise and effects due to residual 
% differences in functional and gyral anatomy during inter-subject 
% averaging.
%
% Inputs
%
% *.img conforming to SPM data format (see 'Data')
%
% Outputs
%
% The smoothed images are written to the same subdirectories as the 
% original *.img and are prefixed with a 's' (i.e. s*.img)
%
%__________________________________________________________________________
% %W% %E%

% get filenames and kernel width
%----------------------------------------------------------------------------
spm_figure('Clear','Interactive');
set(spm_figure('FindWin','Interactive'),'Name','Smoothing')

s     = spm_input('smoothing {FWHM in mm}',1);
P     = spm_get(Inf,'.img','select scans');
n     = size(P,1);
% implement the convolution
%---------------------------------------------------------------------------
set(spm_figure('FindWin','Interactive'),'Name','executing','Pointer','watch');
spm_progress_bar('Init',n,'Smoothing','Volumes Complete');
for i = 1:n
	Q = P(i,:);
	Q = Q(Q ~= ' ');
	d = max([find(Q == '/') 0]);
	U = [Q(1:d) 's' Q((d + 1):length(Q))];
	if ~strcmp(U([1:4] + length(U) - 4),'.img'); U = [U '.img']; end
	spm_smooth(Q,U,s);
	spm_progress_bar('Set',i);
end
spm_figure('Clear','Interactive');

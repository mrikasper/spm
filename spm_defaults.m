function spm_defaults
% Display and changes tp generic SPM parameter defaults 
% FORMAT spm_defaults
%___________________________________________________________________________
%
% spm_defaults allows interactive setting of SPM parameters and header
% defaults.
%
% Header defaults are used only when *.hdr does not exist
%
%---------------------------------------------------------------------------
% CWD       -  working directory for this SPM analysis session
% PRINTSTR  -  a string that is evaluated by spm_print.m 
% LOGFILE   -  File for logging (Not fully supported yet - AH)
% CMDLINE   -  If true, then spm_get & spm_input use the command window.
% GRID      -  this value determines the intensity of any Talairach grids 
%              superimposed on images.  To disable the grid set GRID to 0.
%
% Image header defaults:
%
% DIM      -  image size in x,y and z {voxels}
% VOX      -  voxel size in x,y and z {mm}
% SCALE    -  scaling co-efficient applied to *.img data on entry into SPM. 
% TYPE     -  data type.  (see spm_type.m for supported types and specifiers)
% OFFSET   -  offest of the image data in file {bytes}
% ORIGN    -  the voxel corresponding the [0 0 0] in the location vector XYZ
% DESCRIP  -  a string describing the nature of the image data.
%
% see spm_image.m for editing header files
% see spm_type.m for datatypes that are supported
%
%__________________________________________________________________________
% %W% %E%


figure(2); clf, set(2,'Name','SPM Defaults Edit...')
global CWD PRINTSTR LOGFILE CMDLINE GRID DIM VOX TYPE SCALE OFFSET ORIGIN DESCRIP

% scale positions according to size of figure 2
%---------------------------------------------------------------------------
set(2,'Units','Pixels');
A    = get(2,'Position');
A    = diag([A(3)/400 A(4)/395 A(3)/400 A(4)/395 ]);

% text frames and labels
%----------------------------------------------------------------------------
uicontrol(2,'Style','Frame','Position',[10 110 380 190]*A);

uicontrol(2,'Style','Text','String','Directory',...
	'HorizontalAlign','Left',...
	'Position',[010 370 060 20]*A);

uicontrol(2,'Style','Text','String','Print string',...
	'HorizontalAlign','Left',...
	'Position',[010 340 060 20]*A);

uicontrol(2,'Style','Text','String','Log file',...
	'HorizontalAlign','Left',...
	'Position',[010 310 060 20]*A);

uicontrol(2,'Style','Text','String','Grid Value',...
	'HorizontalAlign','Left',...
	'Position',[010 080 080 20]*A);

uicontrol(2,'Style','Text','String','Header defaults {x y z}',...
	'HorizontalAlign','Left',...
	'ForegroundColor',[1 0 0],...
	'Position',[100 274 200 20]*A);

uicontrol(2,'Style','Text','String','Image size {voxels}',...
	'HorizontalAlign','Left',...
	'Position',[020 250 130 20]*A);

uicontrol(2,'Style','Text','String','Voxel size {mm}',...
	'HorizontalAlign','Left',...
	'Position',[020 230 120 20]*A);

uicontrol(2,'Style','Text','String','Scaling coefficient',...
	'HorizontalAlign','Left',...
	'Position',[020 210 120 20]*A);

uicontrol(2,'Style','Text','String','Data type',...
	'HorizontalAlign','Left',...
	'Position',[020 190 120 20]*A);

uicontrol(2,'Style','Text','String','Offset {bytes}',...
	'HorizontalAlign','Left',...
	'Position',[020 170 120 20]*A);

uicontrol(2,'Style','Text','String','Origin {voxels}',...
	'HorizontalAlign','Left',...
	'Position',[020 150 120 20]*A);

uicontrol(2,'Style','Text','String','Description',...
	'HorizontalAlign','Left',...
	'Position',[020 130 120 20]*A);


%-User interface controls with Callbacks
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',CWD,...
	'HorizontalAlignment','Left',...
	'Callback',['global CWD, CWD = get(gco,''String'');'],...
	'Position',[080 370 300 20]*A);

uicontrol(2,'Style','Edit','String',PRINTSTR,...
	'HorizontalAlignment','Left',...
	'Callback',['global PRINTSTR, PRINTSTR = get(gco,''String'');'],...
	'Position',[080 340 300 20]*A);

uicontrol(2,'Style','Edit','String',LOGFILE,...
	'HorizontalAlignment','Left',...
	'Callback',['global LOGFILE, LOGFILE = get(gco,''String'');'],...
	'Position',[080 310 300 20]*A);

uicontrol(2,'Style','Slider','Value',GRID,...
	'Callback',['global GRID, GRID = get(gco,''value'');'],...
	'Position',[090 80 140 20]*A);

uicontrol(2,'Style','CheckBox','String','Command line for input',...
	'Value',CMDLINE,...
	'Callback',['global CMDLINE, CMDLINE = get(gco,''value'');'],...
	'HorizontalAlign','Left',...
	'Position',[010 030 180 20]*A);

% Quit
%----------------------------------------------------------------------------
uicontrol(2,'Style','Pushbutton','String','Done',...
	'ForegroundColor','m',...
	'Callback','clf, set(gcf,''Name'','''')',...
	'Position',[330 10 60 20]*A);


% Header defaults
%============================================================================

%-Image dimensions
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',sprintf('%3.0i',DIM(1)),...
	'Callback',['global DIM, DIM(1) = eval(get(gco,''String''));'],...
	'Position',[160 250 40 16]*A);

uicontrol(2,'Style','Edit','String',sprintf('%3.0i',DIM(2)),...
	'Callback',['global DIM, DIM(2) = eval(get(gco,''String''));'],...
	'Position',[220 250 40 16]*A);

uicontrol(2,'Style','Edit','String',sprintf('%3.0i',DIM(3)),...
	'Callback',['global DIM, DIM(3) = eval(get(gco,''String''));'],...
	'Position',[280 250 40 16]*A);

%-Voxel dimensions
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',sprintf('%0.2f',VOX(1)),...
	'Callback',['global VOX, VOX(1) = eval(get(gco,''String''));'],...
	'Position',[160 230 40 16]*A);

uicontrol(2,'Style','Edit','String',sprintf('%0.2f',VOX(2)),...
	'Callback',['global VOX, VOX(2) = eval(get(gco,''String''));'],...
	'Position',[220 230 40 16]*A);

uicontrol(2,'Style','Edit','String',sprintf('%0.2f',VOX(3)),...
	'Callback',['global VOX, VOX(3) = eval(get(gco,''String''));'],...
	'Position',[280 230 40 16]*A);

%-Scale
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',sprintf('%0.3f',SCALE),...
	'Callback',['global SCALE, SCALE = eval(get(gco,''String''));'],...
	'Position',[160 210 80 16]*A);

%-Type
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',sprintf('%d',TYPE),...
	'Callback',['global TYPE, TYPE = eval(get(gco,''String''));'],...
	'Position',[160 190 40 16]*A);

%-Offset
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',sprintf('%d',OFFSET),...
	'Callback',['global OFFSET, OFFSET = eval(get(gco,''String''));'],...
	'Position',[160 170 40 16]*A);


%-Origin
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',sprintf('%3.0i',ORIGIN(1)),...
	'Callback',['global ORIGIN, ORIGIN(1) = eval(get(gco,''String''));'],...
	'Position',[160 150 40 16]*A);

uicontrol(2,'Style','Edit','String',sprintf('%3.0i',ORIGIN(2)),...
	'Callback',['global ORIGIN, ORIGIN(2) = eval(get(gco,''String''));'],...
	'Position',[220 150 40 16]*A);

uicontrol(2,'Style','Edit','String',sprintf('%3.0i',ORIGIN(3)),...
	'Callback',['global ORIGIN, ORIGIN(3) = eval(get(gco,''String''));'],...
	'Position',[280 150 40 16]*A);

%-DESCRIP
%----------------------------------------------------------------------------
uicontrol(2,'Style','Edit','String',DESCRIP,...
	'Callback',['global DESCRIP, DESCRIP = get(gco,''String'');'],...
	'Position',[160 126 160 20]*A);

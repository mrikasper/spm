function varargout = spm_eeg_inv_imag_api(varargin)
% SPM_EEG_INV_IMAG_API M-file for spm_eeg_inv_imag_api.fig
%    FIG = SPM_EEG_INV_IMAG_API launch spm_eeg_inv_imag_api GUI.
%    SPM_EEG_INV_IMAG_API('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 09-Jan-2008 16:12:40
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Jeremie Mattout
% $Id: spm_eeg_inv_imag_api.m 1648 2008-05-15 09:49:36Z stefan $


spm('defaults','EEG');
spm('Clear')

% Launch API
%==========================================================================
if nargin < 2 
    
    % open figure
    %----------------------------------------------------------------------
    fig     = openfig(mfilename,'reuse');
    WS      = spm('WinScale');
    Rect    = spm('WinSize','Menu','raw').*WS;
    set(fig,'units','pixels');
    Fdim    = get(fig,'position');
    set(fig,'position',[Rect(1) Rect(2) Fdim(3) Fdim(4)]);
    handles = guihandles(fig);

    % Use system color scheme for figure:
    %----------------------------------------------------------------------
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    handles.fig = fig;
    guidata(fig,handles);
    
    % intialise with D
    %----------------------------------------------------------------------
    try
        D = spm_eeg_inv_check(varargin{1});
        set(handles.DataFile,'String',D.fname);
        set(handles.Exit,'enable','on')
        cd(D.path);
        handles.D = D;
        Reset(fig, [], handles);
        guidata(fig,handles);
    end
    
% INVOKE NAMED SUBFUNCTION OR CALLBACK
%--------------------------------------------------------------------------
elseif ischar(varargin{1}) 
    if nargout
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
        feval(varargin{:}); % FEVAL switchyard
    end

else
    error(sprintf('Wrong input format\n'));
end

% MAIN FUNCTIONS FOR MODEL SEPCIFICATION AND INVERSION
%==========================================================================

% --- Executes on button press in CreateMeshes.
%--------------------------------------------------------------------------
function CreateMeshes_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_inv_mesh_ui(handles.D);
set(handles.CreateMeshes,'enable','off')
set(handles.Reg2tem,     'enable','off')
Reset(hObject, eventdata, handles);


% --- Executes on button press in Reg2tem.
%--------------------------------------------------------------------------
function Reg2tem_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_inv_template_ui(handles.D);
set(handles.CreateMeshes,'enable','off');
Reset(hObject, eventdata, handles);


% --- Executes on button press in Data Reg.
%--------------------------------------------------------------------------
function DataReg_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_inv_datareg_ui(handles.D);
Reset(hObject, eventdata, handles);


% --- Executes on button press in Forward Model.
%--------------------------------------------------------------------------
function Forward_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_inv_forward_ui(handles.D);
Reset(hObject, eventdata, handles);


% --- Executes on button press in Invert.
%--------------------------------------------------------------------------
function Inverse_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_invert_ui(handles.D);
Reset(hObject, eventdata, handles);


% --- Executes on button press in contrast.
%--------------------------------------------------------------------------
function contrast_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_inv_results_ui(handles.D);
Reset(hObject, eventdata, handles);


% --- Executes on button press in Image.
%--------------------------------------------------------------------------
function Image_Callback(hObject, eventdata,handles)
Qstr      = 'Please choose';
Tstr      = 'Smoothing in mm';
handles.D.inv{handles.D.val}.contrast.smooth  = str2num(questdlg(Qstr,Tstr,'8','12','16','12'));
handles.D.inv{handles.D.val}.contrast.display = 1;
handles.D = spm_eeg_inv_Mesh2Voxels(handles.D);
Reset(hObject, eventdata, handles);



% LOAD AND EXIT
%==========================================================================

% --- Executes on button press in Load.
%--------------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
S = spm_select(1, '.mat', 'Select EEG/MEG mat file');
D = spm_eeg_load(S);

[ok, D] = check(D, 'sensfid');

if ~ok
    if check(D, 'basic')
        warndlg(['The requested file is not ready for source reconstruction.'...
            'Use prep to specify sensors and fiducials.']);
    else
        warndlg('The meeg file is corrupt or incomplete');
    end
    return
end

set(handles.DataFile,'String',D.fname);
set(handles.Exit,'enable','on');
cd(D.path);
handles.D     = D;
Reset(hObject, eventdata, handles);


% --- Executes on button press in Exit.
%--------------------------------------------------------------------------
function Exit_Callback(hObject, eventdata, handles)
D             = handles.D;
D.save;
varargout{1} = handles.D;
assignin('base','D',handles.D)


% FUCNTIONS FOR MANAGING DIFFERENT MODELS
%==========================================================================

% --- Executes on button press in new.
%--------------------------------------------------------------------------
function new_Callback(hObject, eventdata, handles)
D  = handles.D;
if ~isfield(D,'inv')
    val   = 1;
elseif ~length(D.inv)
    val   = 1;
else
    val        = length(D.inv) + 1;
    D.inv{val} = D.inv{D.val};
end

% set D in handles and update analysis specific buttons
%--------------------------------------------------------------------------
D.val     = val;
D         = set_CommentDate(D);
handles.D = D;
set(handles.CreateMeshes,'enable','off')
Reset(hObject, eventdata, handles);

% --- Executes on button press in next.
%--------------------------------------------------------------------------
function next_Callback(hObject, eventdata, handles)
if handles.D.val < length(handles.D.inv)
    handles.D.val = handles.D.val + 1;
end
Reset(hObject, eventdata, handles);


% --- Executes on button press in previous.
%--------------------------------------------------------------------------
function previous_Callback(hObject, eventdata, handles)
if handles.D.val > 1
    handles.D.val = handles.D.val - 1;
end
Reset(hObject, eventdata, handles);


% --- Executes on button press in clear.
%--------------------------------------------------------------------------
function clear_Callback(hObject, eventdata, handles)
try
    inv.comment = handles.D.inv{handles.D.val}.comment;
    inv.date    = handles.D.inv{handles.D.val}.date;
    handles.D.inv{handles.D.val} = inv;
end
Reset(hObject, eventdata, handles);

% --- Executes on button press in delete.
%--------------------------------------------------------------------------
function delete_Callback(hObject, eventdata, handles)
if length(handles.D.inv)
    try
        str = handles.D.inv{handles.D.val}.comment;
        warndlg({'you are about to delete:',str{1}});
        uiwait
    end
    handles.D.inv(handles.D.val) = [];
    handles.D.val                = handles.D.val - 1;
end
Reset(hObject, eventdata, handles);



% Auxillary functions
%==========================================================================
function Reset(hObject, eventdata, handles)

% Check to see if a new analysis is required
%--------------------------------------------------------------------------
try
    set(handles.DataFile,'String',handles.D.fname);
end
if ~isfield(handles.D,'inv')
    new_Callback(hObject, eventdata, handles)
    return
end
if ~length(handles.D.inv)
    new_Callback(hObject, eventdata, handles)
    return
end
try
    val = handles.D.val;
    handles.D.inv{val};
catch
    handles.D.val = 1;
    val           = 1;
end

% analysis specification buttons
%--------------------------------------------------------------------------
Q  = handles.D.inv{val};
set(handles.new,      'enable','on','value',0)
set(handles.clear,    'enable','on','value',0)
set(handles.delete,   'enable','on','value',0)
set(handles.next,     'value',0)
set(handles.previous, 'value',0)

if val < length(handles.D.inv)
    set(handles.next,    'enable','on')
end
if val > 1
    set(handles.previous,'enable','on')
end
if val == 1
    set(handles.previous,'enable','off')
end
if val == length(handles.D.inv)
    set(handles.next,    'enable','off')
end
try
    str = sprintf('%i: %s',val,Q.comment{1});
catch
    try
        str = sprintf('%i: %s',val,Q.comment);
    catch
        str = sprintf('%i',val);
    end
end
set(handles.val, 'Value',val,'string',str);

% condition specification
%--------------------------------------------------------------------------
try
    handles.D.con = max(handles.D.con,1);
    if handles.D.con > length(handles.D.inv{val}.inverse.J);
       handles.D.con = 1;
    end
catch
    try 
       handles.D.con = length(handles.D.inv{val}.inverse.J);
    catch
       handles.D.con = 0;
    end
end
if handles.D.con
    str = sprintf('condition %d',handles.D.con);
    set(handles.con,'String',str,'Enable','on','Value',0)
else
    set(handles.con,'Enable','off','Value',0)
end


% check anaylsis buttons
%--------------------------------------------------------------------------
set(handles.DataReg, 'enable','off')
set(handles.Forward, 'enable','off')
set(handles.Inverse, 'enable','off')
set(handles.contrast,'enable','off')
set(handles.Image,   'enable','off')

set(handles.CheckReg,     'enable','off','Value',0)
set(handles.CheckMesh,    'enable','off','Value',0)
set(handles.CheckForward, 'enable','off','Value',0)
set(handles.CheckInverse, 'enable','off','Value',0)
set(handles.CheckContrast,'enable','off','Value',0)
set(handles.CheckImage,   'enable','off','Value',0)
set(handles.Movie,        'enable','off','Value',0)
set(handles.Vis3D,        'enable','off','Value',0)
set(handles.Image,        'enable','off','Value',0)

if isfield(Q, 'mesh')
    set(handles.DataReg,  'enable','on')
    set(handles.CheckMesh,'enable','off')
    if isfield(Q,'datareg') && isfield(Q.datareg, 'sensors')
        set(handles.Forward, 'enable','on')
        set(handles.CheckReg,'enable','on')
        if isfield(Q,'forward') && isfield(Q.forward, 'gainmat')
            set(handles.Inverse,     'enable','on')
            set(handles.CheckForward,'enable','on')
            if isfield(Q,'inverse')
                set(handles.CheckInverse,'enable','on')
                if isfield(Q.inverse,'J')
                    set(handles.contrast,    'enable','on')
                    set(handles.Movie,       'enable','on')
                    set(handles.Vis3D,       'enable','on')
                    if isfield(Q,'contrast')
                        set(handles.CheckContrast,'enable','on')
                        set(handles.Image,        'enable','on')
                        if isfield(Q.contrast,'fname')
                            set(handles.CheckImage,'enable','on')
                        end
                    end
                end
            end
        end
    end
end
try
    if strcmp(handles.D.inv{handles.D.val}.method,'Imaging')
        set(handles.CheckInverse,'String','mip');
        set(handles.PST,'Enable','on');
    else
        set(handles.CheckInverse,'String','dip');
        set(handles.PST,'Enable','off');
    end
end
set(handles.fig,'Pointer','arrow')
assignin('base','D',handles.D)
guidata(hObject,handles);


% Set Comment and Date for new inverse analysis
%--------------------------------------------------------------------------
function S = set_CommentDate(D)

clck = fix(clock);
if clck(5) < 10
    clck = [num2str(clck(4)) ':0' num2str(clck(5))];
else
    clck = [num2str(clck(4)) ':' num2str(clck(5))];
end
D.inv{D.val}.date    = strvcat(date,clck);
D.inv{D.val}.comment = inputdlg('Comment/Label for this analysis:');
S = D;


% CHECKS AND DISPLAYS
%==========================================================================

% --- Executes on button press in CheckMesh.
%--------------------------------------------------------------------------
function CheckMesh_Callback(hObject, eventdata, handles)
spm_eeg_inv_checkmeshes(handles.D);
Reset(hObject, eventdata, handles);

% --- Executes on button press in CheckReg.
%--------------------------------------------------------------------------
function CheckReg_Callback(hObject, eventdata, handles)

D = handles.D;

S =[];

switch D.inv{D.val}.modality
    case 'EEG'
        S.sens = D.inv{D.val}.datareg.sensors;
    case 'MEG'
        % FIXME This is a temporary dirty fix for CTF MEG before 3D layout
        % is available
        sens = D.inv{D.val}.datareg.sensors;
        [sel1 sel2] = spm_match_str(D.inv{D.val}.forward.channels, sens.label);
        S.sens = [];
        S.sens.label = D.inv{D.val}.forward.channels;
        pnt = ((sens.tra)./repmat(sum(sens.tra, 2), 1, size(sens.tra, 2)))*sens.pnt;
        S.sens.pnt = pnt(sel2 ,:);
end
        
S.meegfid = D.inv{D.val}.datareg.fid_eeg;
S.vol = D.inv{D.val}.forward.vol;
S.mrifid = D.inv{D.val}.datareg.fid_mri;
S.mesh = D.inv{D.val}.mesh;

% check and display registration
%--------------------------------------------------------------------------
spm_eeg_inv_checkdatareg(S);

Reset(hObject, eventdata, handles);

% --- Executes on button press in CheckForward.
%--------------------------------------------------------------------------
function CheckForward_Callback(hObject, eventdata, handles)
spm_eeg_inv_checkforward(handles.D);
Reset(hObject, eventdata, handles);

% --- Executes on button press in CheckInverse.
%--------------------------------------------------------------------------
function CheckInverse_Callback(hObject, eventdata, handles)
if strcmp(handles.D.inv{handles.D.val}.method,'Imaging')
    PST    = str2num(get(handles.PST,'String'));
    spm_eeg_invert_display(handles.D,PST);
else
    resdip = handles.D.inv{handles.D.val}.inverse.resdip;
    sMRI   = handles.D.inv{handles.D.val}.mesh.sMRI
    spm_eeg_inv_ecd_DrawDip('Init',resdip,sMRI);
end
Reset(hObject, eventdata, handles);

% --- Executes on button press in Movie.
%--------------------------------------------------------------------------
function Movie_Callback(hObject, eventdata, handles)
figure(spm_figure('GetWin','Graphics'));
PST(1) = str2num(get(handles.Start,'String'));
PST(2) = str2num(get(handles.Stop ,'String'));
spm_eeg_invert_display(handles.D,PST);
Reset(hObject, eventdata, handles);

% --- Executes on button press in CheckContrast.
%--------------------------------------------------------------------------
function CheckContrast_Callback(hObject, eventdata, handles)
spm_eeg_inv_results_display(handles.D);
Reset(hObject, eventdata, handles);

% --- Executes on button press in Vis3D.
%--------------------------------------------------------------------------
function Vis3D_Callback(hObject, eventdata, handles)
Exit_Callback(hObject, eventdata, handles)
spm_eeg_inv_visu3D_api(handles.D);
Reset(hObject, eventdata, handles);

% --- Executes on button press in CheckImage.
%--------------------------------------------------------------------------
function CheckImage_Callback(hObject, eventdata, handles)
spm_eeg_inv_image_display(handles.D)
Reset(hObject, eventdata, handles);

% --- Executes on button press in con.
%--------------------------------------------------------------------------
function con_Callback(hObject, eventdata, handles)
try
    handles.D.con = handles.D.con + 1;
    if handles.D.con > length(handles.D.inverse.J);
        handles.D.con = 1
    end
end
Reset(hObject, eventdata, handles);

% --- Executes on button press in help.
%--------------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
edit spm_eeg_inv_help


% --- Executes on button press in group.
%--------------------------------------------------------------------------
function group_Callback(hObject, eventdata, handles)
spm_eeg_inv_group


% --- Executes on button press in fusion.
%--------------------------------------------------------------------------
function fusion_Callback(hObject, eventdata, handles)
handles.D = spm_eeg_invert_fuse_ui;
Reset(hObject, eventdata, handles)



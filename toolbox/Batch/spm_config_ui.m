function opts = spm_config_ui
% Configuration file for User Interface
%_______________________________________________________________________
% %W% %E%

%_______________________________________________________________________

w = spm_jobman('HelpWidth');

%_______________________________________________________________________
col1 = struct('type','entry','name','Background Colour 1','tag','colour1',...
              'def','ui.colour1','num',[1 3],'strtype','e','val',{{[.8 .8 1]}},...
              'extras',[0 1]);
col2 = struct('type','entry','name','Background Colour 2','tag','colour2',...
              'def','ui.colour2','num',[1 3],'strtype','e','val',{{[1 1 .8]}},...
              'extras',[0 1]);
col3 = struct('type','entry','name','Foreground Colour','tag','colour3',...
              'def','ui.colour3','num',[1 3],'strtype','e','val',{{[0 0 0]}},...
              'extras',[0 1]);

fs   = struct('type','menu','name','Font Size','tag','fs',...
              'def','ui.fs',...
              'labels',{{'8','9','10','12','14','16','18'}},...
              'values',{{ 8 , 9 , 10 , 12 , 14 , 16 , 18 }});


% This is currently unused, but may be unleased when the world is ready for it
a4p       = struct('PaperType','A4',       'dim',[210   297  ],'PaperOrientation','Portrait');
usletterp = struct('PaperType','USLetter', 'dim',[215.9 279.4],'PaperOrientation','Portrait');
a4l       = struct('PaperType','A4',       'dim',[297   210  ],'PaperOrientation','Landscape');
usletterl = struct('PaperType','USLetter', 'dim',[279.4 215.9],'PaperOrientation','Landscape');
pap = struct('type','menu','name','Paper Size','tag','papersize',...
    'labels',{{'A4 [Portrait]','US Letter [Portrait]','A4 [Landscape]','US Letter [Landscape]'}},...
    'values',{{a4p,usletterp,a4l,usletterl}},'val',{{usletterl}},...
    'prog',@resize,'def','ui.paper');


app.type = 'branch';
app.name = 'Appearance';
app.tag  = 'disp';
app.val  = {col1,col2,col3,fs};
app.help = spm_justify(w, 'Appearance of user interface');

opt.type   = 'menu';
opt.name   = 'Printing';
opt.tag    = 'print';
opt.def    = 'ui.print';
opt.labels = {...
    'PostScript for black and white printers',...
    'PostScript for colour printers',...
    'Level 2 PostScript for black and white printers',...
    'Level 2 PostScript for colour printers',...
    'Encapsulated PostScript (EPSF)',...
    'Encapsulated Colour PostScript (EPSF)',...
    'Encapsulated Level 2 PostScript (EPSF)',...
    'Encapsulated Level 2 Color PostScript (EPSF)',...
    'Encapsulated                with TIFF preview',...
    'Encapsulated Colour         with TIFF preview',...
    'Encapsulated Level 2        with TIFF preview',...
    'Encapsulated Level 2 Colour with TIFF preview',...
    'HPGL compatible with Hewlett-Packard 7475A plotter',...
    'Adobe Illustrator 88 compatible illustration file',...
    'M-file (and Mat-file, if necessary)',...
    'Baseline JPEG image',...
    'TIFF with packbits compression',...
    'Color image format'};

pop = inline('struct(''opt'',{opt},''append'',app,''ext'',ext)','opt','app','ext');
opt.val = {pop({'-dpsc2','-append'},true,'.ps')};
opt.values  = {...
    pop({'-dps','-append'},true,'.ps'),...
    pop({'-dpsc','-append'},true,'.ps'),...
    pop({'-dps2','-append'},true,'.ps'),...
    pop({'-dpsc2','-append'},true,'.ps')...
    pop({'-deps'},false,'.eps'),...
    pop({'-depsc'},false,'.eps'),...
    pop({'-deps2'},false,'.eps'),...
    pop({'-depsc2'},false,'.eps'),...
    pop({'-deps','-tiff'},false,'.eps'),...
    pop({'-depsc','-tiff'},false,'.eps'),...
    pop({'-deps2','-tiff'},false,'.eps'),...
    pop({'-depsc2','-tiff'},false,'.eps'),...
    pop({'-dhpgl'},false,'.hpgl'),...
    pop({'-dill'},false,'.ill'),...
    pop({'-dmfile'},false,'.m'),...
    pop({'-djpeg'},false,'.jpg'),...
    pop({'-dtiff'},false,'.tif'),...
    pop({'-dtiffnocompression'},false,'.tif')};
opt.help    = spm_justify(w,[...
    'Select the printing option you want.  The figure will be printed to ',...
    'a file named spm5*.*, in the current directory.  PostScript files will ',...
    'be appended to, but other files will have "page numbers" appended to ',...
    'them.']);

opts = struct('type','branch','name','User Interface','tag','ui','val',{{app,opt}});

% Unused code
function resize(val)
fg = findobj(0,'tag','Graphics');
if length(fg)~=1, return; end;
S0  = get(0,'ScreenSize');
S0  = S0(3:4);
pos = get(fg,'Position');
pos(1:2) = [(pos(1)+pos(3)) (pos(2)+pos(4))]/2;
pos(3:4) = min(0.9*(S0./val.dim))*val.dim;
pos(1:2) = pos(1:2)-pos(3:4)/2;
set(fg,'PaperType',val.PaperType,'Position',pos,'PaperOrientation',val.PaperOrientation);
return;

%function s = pop(opt,app,ext)
%s = struct('opt',{opt},'append',app,'ext',ext);


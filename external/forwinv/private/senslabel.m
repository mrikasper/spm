function label = senslabel(type)

% SENLABEL returns a list of sensor labels given the MEEG system type
%
% Use as
%    label = senslabel(type)
%
% The input type can be any of the following
%   'biosemi64'
%   'biosemi128'
%   'biosemi256'
%   'bti148'
%   'bti148_planar'
%   'bti248'
%   'bti248_planar'
%   'btiref'
%   'ctf151'
%   'ctf151_planar'
%   'ctf275'
%   'ctf275_planar'
%   'ctfheadloc'
%   'ctfref'
%   'eeg1005'
%   'eeg1010'
%   'eeg1020'
%   'egi128'
%   'egi256'
%   'egi32'
%   'egi64'
%   'ext1020'
%   'neuromag122'
%   'neuromag122alt'
%   'neuromag306'
%   'neuromag306alt'
%
% See also SENSTYPE, CHANNELSELECTION

% FIXME one channel is missing for ctf275

% Copyright (C) 2007-2008, Robert Oostenveld
% Copyright (C) 2008, Vladimir Litvak
%
% $Log: senslabel.m,v $
% Revision 1.3  2009/06/19 16:51:50  vlalit
% Added biosemi64 system of  Diane Whitmer, I don't know how generic it is.
%
% Revision 1.2  2009/05/07 13:34:09  roboos
% added ctf64
%
% Revision 1.1  2009/01/21 10:32:38  roboos
% moved from forwinv/* and forwinv/mex/* directory to forwinv/private/* to make the CVS layout consistent with the release version
%
% Revision 1.4  2008/09/17 19:35:07  roboos
% ensure that it returns column array
%
% Revision 1.3  2008/09/10 09:12:11  roboos
% added alternative definition of channel names without a space in the label for neuromag 122 and 306
%
% Revision 1.2  2008/09/10 08:33:36  roboos
% speeded up with factor 5 by performing an initial check on the desired type and subsequently only defining the related variables
%
% Revision 1.1  2008/09/10 07:53:27  roboos
% moved definition of channel label sets to seperate function
%

%  prevent defining all possible labels if not needed
isbiosemi  = ~isempty(regexp(type, '^biosemi', 'once'));
isbti      = ~isempty(regexp(type, '^bti', 'once'));
isctf      = ~isempty(regexp(type, '^ctf', 'once'));
iseeg      = ~isempty(regexp(type, '^eeg', 'once'));
isext      = ~isempty(regexp(type, '^ext', 'once'));
isegi      = ~isempty(regexp(type, '^egi', 'once'));
isneuromag = ~isempty(regexp(type, '^neuromag', 'once'));

if isbti
    btiref = {
        'MRxA'
        'MRyA'
        'MRzA'
        'MLxA'
        'MLyA'
        'MLzA'
        'MCxA'
        'MCyA'
        'MCzA'
        'MRxaA'
        'MRyaA'
        'MRzaA'
        'MLxaA'
        'MLyaA'
        'MLzaA'
        'MCxaA'
        'MCyaA'
        'MCzaA'
        'GxxA'
        'GyxA'
        'GzxA'
        'GyyA'
        'GzyA'
        };

    bti148 = cell(148,1);
    for i=1:148
        bti148{i,1} = sprintf('A%d', i);
    end

    bti148_planar = cell(148,1);
    for i=1:148
        bti148_planar{i,1} = sprintf('A%d_dH', i);
        bti148_planar{i,2} = sprintf('A%d_dV', i);
    end

    bti248 = cell(248,1);
    for i=1:248
        bti248{i,1} = sprintf('A%d', i);
    end

    bti248_planar = cell(248,2);
    for i=1:248
        bti248_planar{i,1} = sprintf('A%d_dH', i);
        bti248_planar{i,2} = sprintf('A%d_dV', i);
    end
end % if isbti

if isctf
    ctfref = {
        'BG1'
        'BG2'
        'BG3'
        'BP1'
        'BP2'
        'BP3'
        'BR1'
        'BR2'
        'BR3'
        'G11'
        'G12'
        'G13'
        'G22'
        'G23'
        'P11'
        'P12'
        'P13'
        'P22'
        'P23'
        'Q11'
        'Q12'
        'Q13'
        'Q22'
        'Q23'
        'R11'
        'R12'
        'R13'
        'R22'
        'R23'
        };

    ctfheadloc = {
        'HLC0011'
        'HLC0012'
        'HLC0013'
        'HLC0021'
        'HLC0022'
        'HLC0023'
        'HLC0031'
        'HLC0032'
        'HLC0033'
        'HLC0018'
        'HLC0028'
        'HLC0038'
        'HLC0014'
        'HLC0015'
        'HLC0016'
        'HLC0017'
        'HLC0024'
        'HLC0025'
        'HLC0026'
        'HLC0027'
        'HLC0034'
        'HLC0035'
        'HLC0036'
        'HLC0037'
        };

    ctf64 = {
        'SL11'
        'SL12'
        'SL13'
        'SL14'
        'SL15'
        'SL16'
        'SL17'
        'SL18'
        'SL19'
        'SL21'
        'SL22'
        'SL23'
        'SL24'
        'SL25'
        'SL26'
        'SL27'
        'SL28'
        'SL29'
        'SL31'
        'SL32'
        'SL33'
        'SL34'
        'SL35'
        'SL41'
        'SL42'
        'SL43'
        'SL44'
        'SL45'
        'SL46'
        'SL47'
        'SL51'
        'SL52'
        'SR11'
        'SR12'
        'SR13'
        'SR14'
        'SR15'
        'SR16'
        'SR17'
        'SR18'
        'SR19'
        'SR21'
        'SR22'
        'SR23'
        'SR24'
        'SR25'
        'SR26'
        'SR27'
        'SR28'
        'SR29'
        'SR31'
        'SR32'
        'SR33'
        'SR34'
        'SR35'
        'SR41'
        'SR42'
        'SR43'
        'SR44'
        'SR45'
        'SR46'
        'SR47'
        'SR51'
        'SR52'
        };

    ctf151 = {
        'MLC11'
        'MLC12'
        'MLC13'
        'MLC14'
        'MLC15'
        'MLC21'
        'MLC22'
        'MLC23'
        'MLC24'
        'MLC31'
        'MLC32'
        'MLC33'
        'MLC41'
        'MLC42'
        'MLC43'
        'MLF11'
        'MLF12'
        'MLF21'
        'MLF22'
        'MLF23'
        'MLF31'
        'MLF32'
        'MLF33'
        'MLF34'
        'MLF41'
        'MLF42'
        'MLF43'
        'MLF44'
        'MLF45'
        'MLF51'
        'MLF52'
        'MLO11'
        'MLO12'
        'MLO21'
        'MLO22'
        'MLO31'
        'MLO32'
        'MLO33'
        'MLO41'
        'MLO42'
        'MLO43'
        'MLP11'
        'MLP12'
        'MLP13'
        'MLP21'
        'MLP22'
        'MLP31'
        'MLP32'
        'MLP33'
        'MLP34'
        'MLT11'
        'MLT12'
        'MLT13'
        'MLT14'
        'MLT15'
        'MLT16'
        'MLT21'
        'MLT22'
        'MLT23'
        'MLT24'
        'MLT25'
        'MLT26'
        'MLT31'
        'MLT32'
        'MLT33'
        'MLT34'
        'MLT35'
        'MLT41'
        'MLT42'
        'MLT43'
        'MLT44'
        'MRC11'
        'MRC12'
        'MRC13'
        'MRC14'
        'MRC15'
        'MRC21'
        'MRC22'
        'MRC23'
        'MRC24'
        'MRC31'
        'MRC32'
        'MRC33'
        'MRC41'
        'MRC42'
        'MRC43'
        'MRF11'
        'MRF12'
        'MRF21'
        'MRF22'
        'MRF23'
        'MRF31'
        'MRF32'
        'MRF33'
        'MRF34'
        'MRF41'
        'MRF42'
        'MRF43'
        'MRF44'
        'MRF45'
        'MRF51'
        'MRF52'
        'MRO11'
        'MRO12'
        'MRO21'
        'MRO22'
        'MRO31'
        'MRO32'
        'MRO33'
        'MRO41'
        'MRO42'
        'MRO43'
        'MRP11'
        'MRP12'
        'MRP13'
        'MRP21'
        'MRP22'
        'MRP31'
        'MRP32'
        'MRP33'
        'MRP34'
        'MRT11'
        'MRT12'
        'MRT13'
        'MRT14'
        'MRT15'
        'MRT16'
        'MRT21'
        'MRT22'
        'MRT23'
        'MRT24'
        'MRT25'
        'MRT26'
        'MRT31'
        'MRT32'
        'MRT33'
        'MRT34'
        'MRT35'
        'MRT41'
        'MRT42'
        'MRT43'
        'MRT44'
        'MZC01'
        'MZC02'
        'MZF01'
        'MZF02'
        'MZF03'
        'MZO01'
        'MZO02'
        'MZP01'
        'MZP02'
        };

    ctf151_planar = cell(151, 2);
    for i=1:151
        ctf151_planar{i,1} = sprintf('%s_dH', ctf151{i});
        ctf151_planar{i,2} = sprintf('%s_dV', ctf151{i});
    end

    ctf275 = {
        'MLC11'
        'MLC12'
        'MLC13'
        'MLC14'
        'MLC15'
        'MLC16'
        'MLC17'
        'MLC21'
        'MLC22'
        'MLC23'
        'MLC24'
        'MLC25'
        'MLC31'
        'MLC32'
        'MLC41'
        'MLC42'
        'MLC51'
        'MLC52'
        'MLC53'
        'MLC54'
        'MLC55'
        'MLC61'
        'MLC62'
        'MLC63'
        'MLF11'
        'MLF12'
        'MLF13'
        'MLF14'
        'MLF21'
        'MLF22'
        'MLF23'
        'MLF24'
        'MLF25'
        'MLF31'
        'MLF32'
        'MLF33'
        'MLF34'
        'MLF35'
        'MLF41'
        'MLF42'
        'MLF43'
        'MLF44'
        'MLF45'
        'MLF46'
        'MLF51'
        'MLF52'
        'MLF53'
        'MLF54'
        'MLF55'
        'MLF56'
        'MLF61'
        'MLF62'
        'MLF63'
        'MLF64'
        'MLF65'
        'MLF66'
        'MLF67'
        'MLO11'
        'MLO12'
        'MLO13'
        'MLO14'
        'MLO21'
        'MLO22'
        'MLO23'
        'MLO24'
        'MLO31'
        'MLO32'
        'MLO33'
        'MLO34'
        'MLO41'
        'MLO42'
        'MLO43'
        'MLO44'
        'MLO51'
        'MLO52'
        'MLO53'
        'MLP11'
        'MLP12'
        'MLP21'
        'MLP22'
        'MLP23'
        'MLP31'
        'MLP32'
        'MLP33'
        'MLP34'
        'MLP35'
        'MLP41'
        'MLP42'
        'MLP43'
        'MLP44'
        'MLP45'
        'MLP51'
        'MLP52'
        'MLP53'
        'MLP54'
        'MLP55'
        'MLP56'
        'MLP57'
        'MLT11'
        'MLT12'
        'MLT13'
        'MLT14'
        'MLT15'
        'MLT16'
        'MLT21'
        'MLT22'
        'MLT23'
        'MLT24'
        'MLT25'
        'MLT26'
        'MLT27'
        'MLT31'
        'MLT32'
        'MLT33'
        'MLT34'
        'MLT35'
        'MLT36'
        'MLT37'
        'MLT41'
        'MLT42'
        'MLT43'
        'MLT44'
        'MLT45'
        'MLT46'
        'MLT47'
        'MLT51'
        'MLT52'
        'MLT53'
        'MLT54'
        'MLT55'
        'MLT56'
        'MLT57'
        'MRC11'
        'MRC12'
        'MRC13'
        'MRC14'
        'MRC15'
        'MRC16'
        'MRC17'
        'MRC21'
        'MRC22'
        'MRC23'
        'MRC24'
        'MRC25'
        'MRC31'
        'MRC32'
        'MRC41'
        'MRC42'
        'MRC51'
        'MRC52'
        'MRC53'
        'MRC54'
        'MRC55'
        'MRC61'
        'MRC62'
        'MRC63'
        'MRF11'
        'MRF12'
        'MRF13'
        'MRF14'
        'MRF21'
        'MRF22'
        'MRF23'
        'MRF24'
        'MRF25'
        'MRF31'
        'MRF32'
        'MRF33'
        'MRF34'
        'MRF35'
        'MRF41'
        'MRF42'
        'MRF43'
        'MRF44'
        'MRF45'
        'MRF46'
        'MRF51'
        'MRF52'
        'MRF53'
        'MRF54'
        'MRF55'
        'MRF56'
        'MRF61'
        'MRF62'
        'MRF63'
        'MRF64'
        'MRF65'
        'MRF66'
        'MRF67'
        'MRO11'
        'MRO12'
        'MRO13'
        'MRO14'
        'MRO21'
        'MRO22'
        'MRO23'
        'MRO24'
        'MRO31'
        'MRO32'
        'MRO33'
        'MRO34'
        'MRO41'
        'MRO42'
        'MRO43'
        'MRO44'
        'MRO51'
        'MRO52'
        'MRO53'
        'MRP11'
        'MRP12'
        'MRP21'
        'MRP22'
        'MRP23'
        'MRP32'
        'MRP33'
        'MRP34'
        'MRP35'
        'MRP41'
        'MRP42'
        'MRP43'
        'MRP44'
        'MRP45'
        'MRP51'
        'MRP52'
        'MRP53'
        'MRP54'
        'MRP55'
        'MRP56'
        'MRP57'
        'MRT11'
        'MRT12'
        'MRT13'
        'MRT14'
        'MRT15'
        'MRT16'
        'MRT21'
        'MRT22'
        'MRT23'
        'MRT24'
        'MRT25'
        'MRT26'
        'MRT27'
        'MRT31'
        'MRT32'
        'MRT33'
        'MRT34'
        'MRT35'
        'MRT36'
        'MRT37'
        'MRT41'
        'MRT42'
        'MRT43'
        'MRT44'
        'MRT45'
        'MRT46'
        'MRT47'
        'MRT51'
        'MRT52'
        'MRT53'
        'MRT54'
        'MRT55'
        'MRT56'
        'MRT57'
        'MZC01'
        'MZC02'
        'MZC03'
        'MZC04'
        'MZF01'
        'MZF02'
        'MZF03'
        'MZO01'
        'MZO02'
        'MZO03'
        'MZP01'
        };

    % f.ck, apparently one channel is missing
    ctf275_planar = cell(274,2);
    for i=1:274
        ctf275_planar{i,1} = sprintf('%s_dH', ctf275{i});
        ctf275_planar{i,2} = sprintf('%s_dV', ctf275{i});
    end
end % if issctf

if isneuromag
    neuromag122 = {
        'MEG 001'    'MEG 002'
        'MEG 003'    'MEG 004'
        'MEG 005'    'MEG 006'
        'MEG 007'    'MEG 008'
        'MEG 009'    'MEG 010'
        'MEG 011'    'MEG 012'
        'MEG 013'    'MEG 014'
        'MEG 015'    'MEG 016'
        'MEG 017'    'MEG 018'
        'MEG 019'    'MEG 020'
        'MEG 021'    'MEG 022'
        'MEG 023'    'MEG 024'
        'MEG 025'    'MEG 026'
        'MEG 027'    'MEG 028'
        'MEG 029'    'MEG 030'
        'MEG 031'    'MEG 032'
        'MEG 033'    'MEG 034'
        'MEG 035'    'MEG 036'
        'MEG 037'    'MEG 038'
        'MEG 039'    'MEG 040'
        'MEG 041'    'MEG 042'
        'MEG 043'    'MEG 044'
        'MEG 045'    'MEG 046'
        'MEG 047'    'MEG 048'
        'MEG 049'    'MEG 050'
        'MEG 051'    'MEG 052'
        'MEG 053'    'MEG 054'
        'MEG 055'    'MEG 056'
        'MEG 057'    'MEG 058'
        'MEG 059'    'MEG 060'
        'MEG 061'    'MEG 062'
        'MEG 063'    'MEG 064'
        'MEG 065'    'MEG 066'
        'MEG 067'    'MEG 068'
        'MEG 069'    'MEG 070'
        'MEG 071'    'MEG 072'
        'MEG 073'    'MEG 074'
        'MEG 075'    'MEG 076'
        'MEG 077'    'MEG 078'
        'MEG 079'    'MEG 080'
        'MEG 081'    'MEG 082'
        'MEG 083'    'MEG 084'
        'MEG 085'    'MEG 086'
        'MEG 087'    'MEG 088'
        'MEG 089'    'MEG 090'
        'MEG 091'    'MEG 092'
        'MEG 093'    'MEG 094'
        'MEG 095'    'MEG 096'
        'MEG 097'    'MEG 098'
        'MEG 099'    'MEG 100'
        'MEG 101'    'MEG 102'
        'MEG 103'    'MEG 104'
        'MEG 105'    'MEG 106'
        'MEG 107'    'MEG 108'
        'MEG 109'    'MEG 110'
        'MEG 111'    'MEG 112'
        'MEG 113'    'MEG 114'
        'MEG 115'    'MEG 116'
        'MEG 117'    'MEG 118'
        'MEG 119'    'MEG 120'
        'MEG 121'    'MEG 122'
        };

    % this is an alternative set of labels without a space in them
    neuromag122alt = {
        'MEG001'    'MEG002'
        'MEG003'    'MEG004'
        'MEG005'    'MEG006'
        'MEG007'    'MEG008'
        'MEG009'    'MEG010'
        'MEG011'    'MEG012'
        'MEG013'    'MEG014'
        'MEG015'    'MEG016'
        'MEG017'    'MEG018'
        'MEG019'    'MEG020'
        'MEG021'    'MEG022'
        'MEG023'    'MEG024'
        'MEG025'    'MEG026'
        'MEG027'    'MEG028'
        'MEG029'    'MEG030'
        'MEG031'    'MEG032'
        'MEG033'    'MEG034'
        'MEG035'    'MEG036'
        'MEG037'    'MEG038'
        'MEG039'    'MEG040'
        'MEG041'    'MEG042'
        'MEG043'    'MEG044'
        'MEG045'    'MEG046'
        'MEG047'    'MEG048'
        'MEG049'    'MEG050'
        'MEG051'    'MEG052'
        'MEG053'    'MEG054'
        'MEG055'    'MEG056'
        'MEG057'    'MEG058'
        'MEG059'    'MEG060'
        'MEG061'    'MEG062'
        'MEG063'    'MEG064'
        'MEG065'    'MEG066'
        'MEG067'    'MEG068'
        'MEG069'    'MEG070'
        'MEG071'    'MEG072'
        'MEG073'    'MEG074'
        'MEG075'    'MEG076'
        'MEG077'    'MEG078'
        'MEG079'    'MEG080'
        'MEG081'    'MEG082'
        'MEG083'    'MEG084'
        'MEG085'    'MEG086'
        'MEG087'    'MEG088'
        'MEG089'    'MEG090'
        'MEG091'    'MEG092'
        'MEG093'    'MEG094'
        'MEG095'    'MEG096'
        'MEG097'    'MEG098'
        'MEG099'    'MEG100'
        'MEG101'    'MEG102'
        'MEG103'    'MEG104'
        'MEG105'    'MEG106'
        'MEG107'    'MEG108'
        'MEG109'    'MEG110'
        'MEG111'    'MEG112'
        'MEG113'    'MEG114'
        'MEG115'    'MEG116'
        'MEG117'    'MEG118'
        'MEG119'    'MEG120'
        'MEG121'    'MEG122'
        };

    neuromag306 = {
        'MEG 0113'    'MEG 0112'   'MEG 0111'
        'MEG 0122'    'MEG 0123'   'MEG 0121'
        'MEG 0132'    'MEG 0133'   'MEG 0131'
        'MEG 0143'    'MEG 0142'   'MEG 0141'
        'MEG 0213'    'MEG 0212'   'MEG 0211'
        'MEG 0222'    'MEG 0223'   'MEG 0221'
        'MEG 0232'    'MEG 0233'   'MEG 0231'
        'MEG 0243'    'MEG 0242'   'MEG 0241'
        'MEG 0313'    'MEG 0312'   'MEG 0311'
        'MEG 0322'    'MEG 0323'   'MEG 0321'
        'MEG 0333'    'MEG 0332'   'MEG 0331'
        'MEG 0343'    'MEG 0342'   'MEG 0341'
        'MEG 0413'    'MEG 0412'   'MEG 0411'
        'MEG 0422'    'MEG 0423'   'MEG 0421'
        'MEG 0432'    'MEG 0433'   'MEG 0431'
        'MEG 0443'    'MEG 0442'   'MEG 0441'
        'MEG 0513'    'MEG 0512'   'MEG 0511'
        'MEG 0523'    'MEG 0522'   'MEG 0521'
        'MEG 0532'    'MEG 0533'   'MEG 0531'
        'MEG 0542'    'MEG 0543'   'MEG 0541'
        'MEG 0613'    'MEG 0612'   'MEG 0611'
        'MEG 0622'    'MEG 0623'   'MEG 0621'
        'MEG 0633'    'MEG 0632'   'MEG 0631'
        'MEG 0642'    'MEG 0643'   'MEG 0641'
        'MEG 0713'    'MEG 0712'   'MEG 0711'
        'MEG 0723'    'MEG 0722'   'MEG 0721'
        'MEG 0733'    'MEG 0732'   'MEG 0731'
        'MEG 0743'    'MEG 0742'   'MEG 0741'
        'MEG 0813'    'MEG 0812'   'MEG 0811'
        'MEG 0822'    'MEG 0823'   'MEG 0821'
        'MEG 0913'    'MEG 0912'   'MEG 0911'
        'MEG 0923'    'MEG 0922'   'MEG 0921'
        'MEG 0932'    'MEG 0933'   'MEG 0931'
        'MEG 0942'    'MEG 0943'   'MEG 0941'
        'MEG 1013'    'MEG 1012'   'MEG 1011'
        'MEG 1023'    'MEG 1022'   'MEG 1021'
        'MEG 1032'    'MEG 1033'   'MEG 1031'
        'MEG 1043'    'MEG 1042'   'MEG 1041'
        'MEG 1112'    'MEG 1113'   'MEG 1111'
        'MEG 1123'    'MEG 1122'   'MEG 1121'
        'MEG 1133'    'MEG 1132'   'MEG 1131'
        'MEG 1142'    'MEG 1143'   'MEG 1141'
        'MEG 1213'    'MEG 1212'   'MEG 1211'
        'MEG 1223'    'MEG 1222'   'MEG 1221'
        'MEG 1232'    'MEG 1233'   'MEG 1231'
        'MEG 1243'    'MEG 1242'   'MEG 1241'
        'MEG 1312'    'MEG 1313'   'MEG 1311'
        'MEG 1323'    'MEG 1322'   'MEG 1321'
        'MEG 1333'    'MEG 1332'   'MEG 1331'
        'MEG 1342'    'MEG 1343'   'MEG 1341'
        'MEG 1412'    'MEG 1413'   'MEG 1411'
        'MEG 1423'    'MEG 1422'   'MEG 1421'
        'MEG 1433'    'MEG 1432'   'MEG 1431'
        'MEG 1442'    'MEG 1443'   'MEG 1441'
        'MEG 1512'    'MEG 1513'   'MEG 1511'
        'MEG 1522'    'MEG 1523'   'MEG 1521'
        'MEG 1533'    'MEG 1532'   'MEG 1531'
        'MEG 1543'    'MEG 1542'   'MEG 1541'
        'MEG 1613'    'MEG 1612'   'MEG 1611'
        'MEG 1622'    'MEG 1623'   'MEG 1621'
        'MEG 1632'    'MEG 1633'   'MEG 1631'
        'MEG 1643'    'MEG 1642'   'MEG 1641'
        'MEG 1713'    'MEG 1712'   'MEG 1711'
        'MEG 1722'    'MEG 1723'   'MEG 1721'
        'MEG 1732'    'MEG 1733'   'MEG 1731'
        'MEG 1743'    'MEG 1742'   'MEG 1741'
        'MEG 1813'    'MEG 1812'   'MEG 1811'
        'MEG 1822'    'MEG 1823'   'MEG 1821'
        'MEG 1832'    'MEG 1833'   'MEG 1831'
        'MEG 1843'    'MEG 1842'   'MEG 1841'
        'MEG 1912'    'MEG 1913'   'MEG 1911'
        'MEG 1923'    'MEG 1922'   'MEG 1921'
        'MEG 1932'    'MEG 1933'   'MEG 1931'
        'MEG 1943'    'MEG 1942'   'MEG 1941'
        'MEG 2013'    'MEG 2012'   'MEG 2011'
        'MEG 2023'    'MEG 2022'   'MEG 2021'
        'MEG 2032'    'MEG 2033'   'MEG 2031'
        'MEG 2042'    'MEG 2043'   'MEG 2041'
        'MEG 2113'    'MEG 2112'   'MEG 2111'
        'MEG 2122'    'MEG 2123'   'MEG 2121'
        'MEG 2133'    'MEG 2132'   'MEG 2131'
        'MEG 2143'    'MEG 2142'   'MEG 2141'
        'MEG 2212'    'MEG 2213'   'MEG 2211'
        'MEG 2223'    'MEG 2222'   'MEG 2221'
        'MEG 2233'    'MEG 2232'   'MEG 2231'
        'MEG 2242'    'MEG 2243'   'MEG 2241'
        'MEG 2312'    'MEG 2313'   'MEG 2311'
        'MEG 2323'    'MEG 2322'   'MEG 2321'
        'MEG 2332'    'MEG 2333'   'MEG 2331'
        'MEG 2343'    'MEG 2342'   'MEG 2341'
        'MEG 2412'    'MEG 2413'   'MEG 2411'
        'MEG 2423'    'MEG 2422'   'MEG 2421'
        'MEG 2433'    'MEG 2432'   'MEG 2431'
        'MEG 2442'    'MEG 2443'   'MEG 2441'
        'MEG 2512'    'MEG 2513'   'MEG 2511'
        'MEG 2522'    'MEG 2523'   'MEG 2521'
        'MEG 2533'    'MEG 2532'   'MEG 2531'
        'MEG 2543'    'MEG 2542'   'MEG 2541'
        'MEG 2612'    'MEG 2613'   'MEG 2611'
        'MEG 2623'    'MEG 2622'   'MEG 2621'
        'MEG 2633'    'MEG 2632'   'MEG 2631'
        'MEG 2642'    'MEG 2643'   'MEG 2641'
        };

    % this is an alternative set of labels without a space in them
    neuromag306alt = {
        'MEG0113'    'MEG0112'   'MEG0111'
        'MEG0122'    'MEG0123'   'MEG0121'
        'MEG0132'    'MEG0133'   'MEG0131'
        'MEG0143'    'MEG0142'   'MEG0141'
        'MEG0213'    'MEG0212'   'MEG0211'
        'MEG0222'    'MEG0223'   'MEG0221'
        'MEG0232'    'MEG0233'   'MEG0231'
        'MEG0243'    'MEG0242'   'MEG0241'
        'MEG0313'    'MEG0312'   'MEG0311'
        'MEG0322'    'MEG0323'   'MEG0321'
        'MEG0333'    'MEG0332'   'MEG0331'
        'MEG0343'    'MEG0342'   'MEG0341'
        'MEG0413'    'MEG0412'   'MEG0411'
        'MEG0422'    'MEG0423'   'MEG0421'
        'MEG0432'    'MEG0433'   'MEG0431'
        'MEG0443'    'MEG0442'   'MEG0441'
        'MEG0513'    'MEG0512'   'MEG0511'
        'MEG0523'    'MEG0522'   'MEG0521'
        'MEG0532'    'MEG0533'   'MEG0531'
        'MEG0542'    'MEG0543'   'MEG0541'
        'MEG0613'    'MEG0612'   'MEG0611'
        'MEG0622'    'MEG0623'   'MEG0621'
        'MEG0633'    'MEG0632'   'MEG0631'
        'MEG0642'    'MEG0643'   'MEG0641'
        'MEG0713'    'MEG0712'   'MEG0711'
        'MEG0723'    'MEG0722'   'MEG0721'
        'MEG0733'    'MEG0732'   'MEG0731'
        'MEG0743'    'MEG0742'   'MEG0741'
        'MEG0813'    'MEG0812'   'MEG0811'
        'MEG0822'    'MEG0823'   'MEG0821'
        'MEG0913'    'MEG0912'   'MEG0911'
        'MEG0923'    'MEG0922'   'MEG0921'
        'MEG0932'    'MEG0933'   'MEG0931'
        'MEG0942'    'MEG0943'   'MEG0941'
        'MEG1013'    'MEG1012'   'MEG1011'
        'MEG1023'    'MEG1022'   'MEG1021'
        'MEG1032'    'MEG1033'   'MEG1031'
        'MEG1043'    'MEG1042'   'MEG1041'
        'MEG1112'    'MEG1113'   'MEG1111'
        'MEG1123'    'MEG1122'   'MEG1121'
        'MEG1133'    'MEG1132'   'MEG1131'
        'MEG1142'    'MEG1143'   'MEG1141'
        'MEG1213'    'MEG1212'   'MEG1211'
        'MEG1223'    'MEG1222'   'MEG1221'
        'MEG1232'    'MEG1233'   'MEG1231'
        'MEG1243'    'MEG1242'   'MEG1241'
        'MEG1312'    'MEG1313'   'MEG1311'
        'MEG1323'    'MEG1322'   'MEG1321'
        'MEG1333'    'MEG1332'   'MEG1331'
        'MEG1342'    'MEG1343'   'MEG1341'
        'MEG1412'    'MEG1413'   'MEG1411'
        'MEG1423'    'MEG1422'   'MEG1421'
        'MEG1433'    'MEG1432'   'MEG1431'
        'MEG1442'    'MEG1443'   'MEG1441'
        'MEG1512'    'MEG1513'   'MEG1511'
        'MEG1522'    'MEG1523'   'MEG1521'
        'MEG1533'    'MEG1532'   'MEG1531'
        'MEG1543'    'MEG1542'   'MEG1541'
        'MEG1613'    'MEG1612'   'MEG1611'
        'MEG1622'    'MEG1623'   'MEG1621'
        'MEG1632'    'MEG1633'   'MEG1631'
        'MEG1643'    'MEG1642'   'MEG1641'
        'MEG1713'    'MEG1712'   'MEG1711'
        'MEG1722'    'MEG1723'   'MEG1721'
        'MEG1732'    'MEG1733'   'MEG1731'
        'MEG1743'    'MEG1742'   'MEG1741'
        'MEG1813'    'MEG1812'   'MEG1811'
        'MEG1822'    'MEG1823'   'MEG1821'
        'MEG1832'    'MEG1833'   'MEG1831'
        'MEG1843'    'MEG1842'   'MEG1841'
        'MEG1912'    'MEG1913'   'MEG1911'
        'MEG1923'    'MEG1922'   'MEG1921'
        'MEG1932'    'MEG1933'   'MEG1931'
        'MEG1943'    'MEG1942'   'MEG1941'
        'MEG2013'    'MEG2012'   'MEG2011'
        'MEG2023'    'MEG2022'   'MEG2021'
        'MEG2032'    'MEG2033'   'MEG2031'
        'MEG2042'    'MEG2043'   'MEG2041'
        'MEG2113'    'MEG2112'   'MEG2111'
        'MEG2122'    'MEG2123'   'MEG2121'
        'MEG2133'    'MEG2132'   'MEG2131'
        'MEG2143'    'MEG2142'   'MEG2141'
        'MEG2212'    'MEG2213'   'MEG2211'
        'MEG2223'    'MEG2222'   'MEG2221'
        'MEG2233'    'MEG2232'   'MEG2231'
        'MEG2242'    'MEG2243'   'MEG2241'
        'MEG2312'    'MEG2313'   'MEG2311'
        'MEG2323'    'MEG2322'   'MEG2321'
        'MEG2332'    'MEG2333'   'MEG2331'
        'MEG2343'    'MEG2342'   'MEG2341'
        'MEG2412'    'MEG2413'   'MEG2411'
        'MEG2423'    'MEG2422'   'MEG2421'
        'MEG2433'    'MEG2432'   'MEG2431'
        'MEG2442'    'MEG2443'   'MEG2441'
        'MEG2512'    'MEG2513'   'MEG2511'
        'MEG2522'    'MEG2523'   'MEG2521'
        'MEG2533'    'MEG2532'   'MEG2531'
        'MEG2543'    'MEG2542'   'MEG2541'
        'MEG2612'    'MEG2613'   'MEG2611'
        'MEG2623'    'MEG2622'   'MEG2621'
        'MEG2633'    'MEG2632'   'MEG2631'
        'MEG2642'    'MEG2643'   'MEG2641'
        };
end % if isneuromag

if iseeg || isext
    eeg1020 = {
        'Fp1'
        'Fpz'
        'Fp2'
        'F7'
        'F3'
        'Fz'
        'F4'
        'F8'
        'T7'
        'C3'
        'Cz'
        'C4'
        'T8'
        'P7'
        'P3'
        'Pz'
        'P4'
        'P8'
        'O1'
        'Oz'
        'O2'};

    eeg1010 = {
        'Fp1'
        'Fpz'
        'Fp2'
        'AF9'
        'AF7'
        'AF5'
        'AF3'
        'AF1'
        'AFz'
        'AF2'
        'AF4'
        'AF6'
        'AF8'
        'AF10'
        'F9'
        'F7'
        'F5'
        'F3'
        'F1'
        'Fz'
        'F2'
        'F4'
        'F6'
        'F8'
        'F10'
        'FT9'
        'FT7'
        'FC5'
        'FC3'
        'FC1'
        'FCz'
        'FC2'
        'FC4'
        'FC6'
        'FT8'
        'FT10'
        'T9'
        'T7'
        'C5'
        'C3'
        'C1'
        'Cz'
        'C2'
        'C4'
        'C6'
        'T8'
        'T10'
        'TP9'
        'TP7'
        'CP5'
        'CP3'
        'CP1'
        'CPz'
        'CP2'
        'CP4'
        'CP6'
        'TP8'
        'TP10'
        'P9'
        'P7'
        'P5'
        'P3'
        'P1'
        'Pz'
        'P2'
        'P4'
        'P6'
        'P8'
        'P10'
        'PO9'
        'PO7'
        'PO5'
        'PO3'
        'PO1'
        'POz'
        'PO2'
        'PO4'
        'PO6'
        'PO8'
        'PO10'
        'O1'
        'Oz'
        'O2'
        'I1'
        'Iz'
        'I2'
        };

    eeg1005 = {
        'Fp1'
        'Fpz'
        'Fp2'
        'AF9'
        'AF7'
        'AF5'
        'AF3'
        'AF1'
        'AFz'
        'AF2'
        'AF4'
        'AF6'
        'AF8'
        'AF10'
        'F9'
        'F7'
        'F5'
        'F3'
        'F1'
        'Fz'
        'F2'
        'F4'
        'F6'
        'F8'
        'F10'
        'FT9'
        'FT7'
        'FC5'
        'FC3'
        'FC1'
        'FCz'
        'FC2'
        'FC4'
        'FC6'
        'FT8'
        'FT10'
        'T9'
        'T7'
        'C5'
        'C3'
        'C1'
        'Cz'
        'C2'
        'C4'
        'C6'
        'T8'
        'T10'
        'TP9'
        'TP7'
        'CP5'
        'CP3'
        'CP1'
        'CPz'
        'CP2'
        'CP4'
        'CP6'
        'TP8'
        'TP10'
        'P9'
        'P7'
        'P5'
        'P3'
        'P1'
        'Pz'
        'P2'
        'P4'
        'P6'
        'P8'
        'P10'
        'PO9'
        'PO7'
        'PO5'
        'PO3'
        'PO1'
        'POz'
        'PO2'
        'PO4'
        'PO6'
        'PO8'
        'PO10'
        'O1'
        'Oz'
        'O2'
        'I1'
        'Iz'
        'I2'
        'AFp9h'
        'AFp7h'
        'AFp5h'
        'AFp3h'
        'AFp1h'
        'AFp2h'
        'AFp4h'
        'AFp6h'
        'AFp8h'
        'AFp10h'
        'AFF9h'
        'AFF7h'
        'AFF5h'
        'AFF3h'
        'AFF1h'
        'AFF2h'
        'AFF4h'
        'AFF6h'
        'AFF8h'
        'AFF10h'
        'FFT9h'
        'FFT7h'
        'FFC5h'
        'FFC3h'
        'FFC1h'
        'FFC2h'
        'FFC4h'
        'FFC6h'
        'FFT8h'
        'FFT10h'
        'FTT9h'
        'FTT7h'
        'FCC5h'
        'FCC3h'
        'FCC1h'
        'FCC2h'
        'FCC4h'
        'FCC6h'
        'FTT8h'
        'FTT10h'
        'TTP9h'
        'TTP7h'
        'CCP5h'
        'CCP3h'
        'CCP1h'
        'CCP2h'
        'CCP4h'
        'CCP6h'
        'TTP8h'
        'TTP10h'
        'TPP9h'
        'TPP7h'
        'CPP5h'
        'CPP3h'
        'CPP1h'
        'CPP2h'
        'CPP4h'
        'CPP6h'
        'TPP8h'
        'TPP10h'
        'PPO9h'
        'PPO7h'
        'PPO5h'
        'PPO3h'
        'PPO1h'
        'PPO2h'
        'PPO4h'
        'PPO6h'
        'PPO8h'
        'PPO10h'
        'POO9h'
        'POO7h'
        'POO5h'
        'POO3h'
        'POO1h'
        'POO2h'
        'POO4h'
        'POO6h'
        'POO8h'
        'POO10h'
        'OI1h'
        'OI2h'
        'Fp1h'
        'Fp2h'
        'AF9h'
        'AF7h'
        'AF5h'
        'AF3h'
        'AF1h'
        'AF2h'
        'AF4h'
        'AF6h'
        'AF8h'
        'AF10h'
        'F9h'
        'F7h'
        'F5h'
        'F3h'
        'F1h'
        'F2h'
        'F4h'
        'F6h'
        'F8h'
        'F10h'
        'FT9h'
        'FT7h'
        'FC5h'
        'FC3h'
        'FC1h'
        'FC2h'
        'FC4h'
        'FC6h'
        'FT8h'
        'FT10h'
        'T9h'
        'T7h'
        'C5h'
        'C3h'
        'C1h'
        'C2h'
        'C4h'
        'C6h'
        'T8h'
        'T10h'
        'TP9h'
        'TP7h'
        'CP5h'
        'CP3h'
        'CP1h'
        'CP2h'
        'CP4h'
        'CP6h'
        'TP8h'
        'TP10h'
        'P9h'
        'P7h'
        'P5h'
        'P3h'
        'P1h'
        'P2h'
        'P4h'
        'P6h'
        'P8h'
        'P10h'
        'PO9h'
        'PO7h'
        'PO5h'
        'PO3h'
        'PO1h'
        'PO2h'
        'PO4h'
        'PO6h'
        'PO8h'
        'PO10h'
        'O1h'
        'O2h'
        'I1h'
        'I2h'
        'AFp9'
        'AFp7'
        'AFp5'
        'AFp3'
        'AFp1'
        'AFpz'
        'AFp2'
        'AFp4'
        'AFp6'
        'AFp8'
        'AFp10'
        'AFF9'
        'AFF7'
        'AFF5'
        'AFF3'
        'AFF1'
        'AFFz'
        'AFF2'
        'AFF4'
        'AFF6'
        'AFF8'
        'AFF10'
        'FFT9'
        'FFT7'
        'FFC5'
        'FFC3'
        'FFC1'
        'FFCz'
        'FFC2'
        'FFC4'
        'FFC6'
        'FFT8'
        'FFT10'
        'FTT9'
        'FTT7'
        'FCC5'
        'FCC3'
        'FCC1'
        'FCCz'
        'FCC2'
        'FCC4'
        'FCC6'
        'FTT8'
        'FTT10'
        'TTP9'
        'TTP7'
        'CCP5'
        'CCP3'
        'CCP1'
        'CCPz'
        'CCP2'
        'CCP4'
        'CCP6'
        'TTP8'
        'TTP10'
        'TPP9'
        'TPP7'
        'CPP5'
        'CPP3'
        'CPP1'
        'CPPz'
        'CPP2'
        'CPP4'
        'CPP6'
        'TPP8'
        'TPP10'
        'PPO9'
        'PPO7'
        'PPO5'
        'PPO3'
        'PPO1'
        'PPOz'
        'PPO2'
        'PPO4'
        'PPO6'
        'PPO8'
        'PPO10'
        'POO9'
        'POO7'
        'POO5'
        'POO3'
        'POO1'
        'POOz'
        'POO2'
        'POO4'
        'POO6'
        'POO8'
        'POO10'
        'OI1'
        'OIz'
        'OI2'
        };

    % Add also alternative labels that are used in some systems
    ext1020 = cat(1, eeg1005, {'A1' 'A2' 'M1' 'M2' 'T3' 'T4' 'T5' 'T6'}');

    % This is to account for all variants of case in 1020 systems
    ext1020 = unique(cat(1, ext1020, upper(ext1020), lower(ext1020)));
end % if iseeg || isext

if isbiosemi
    biosemi64  = {
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'A8'
        'A9'
        'A10'
        'A11'
        'A12'
        'A13'
        'A14'
        'A15'
        'A16'
        'A17'
        'A18'
        'A19'
        'A20'
        'A21'
        'A22'
        'A23'
        'A24'
        'A25'
        'A26'
        'A27'
        'A28'
        'A29'
        'A30'
        'A31'
        'A32'
        'B1'
        'B2'
        'B3'
        'B4'
        'B5'
        'B6'
        'B7'
        'B8'
        'B9'
        'B10'
        'B11'
        'B12'
        'B13'
        'B14'
        'B15'
        'B16'
        'B17'
        'B18'
        'B19'
        'B20'
        'B21'
        'B22'
        'B23'
        'B24'
        'B25'
        'B26'
        'B27'
        'B28'
        'B29'
        'B30'
        'B31'
        'B32'
        };

    biosemi128 = {
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'A8'
        'A9'
        'A10'
        'A11'
        'A12'
        'A13'
        'A14'
        'A15'
        'A16'
        'A17'
        'A18'
        'A19'
        'A20'
        'A21'
        'A22'
        'A23'
        'A24'
        'A25'
        'A26'
        'A27'
        'A28'
        'A29'
        'A30'
        'A31'
        'A32'
        'B1'
        'B2'
        'B3'
        'B4'
        'B5'
        'B6'
        'B7'
        'B8'
        'B9'
        'B10'
        'B11'
        'B12'
        'B13'
        'B14'
        'B15'
        'B16'
        'B17'
        'B18'
        'B19'
        'B20'
        'B21'
        'B22'
        'B23'
        'B24'
        'B25'
        'B26'
        'B27'
        'B28'
        'B29'
        'B30'
        'B31'
        'B32'
        'C1'
        'C2'
        'C3'
        'C4'
        'C5'
        'C6'
        'C7'
        'C8'
        'C9'
        'C10'
        'C11'
        'C12'
        'C13'
        'C14'
        'C15'
        'C16'
        'C17'
        'C18'
        'C19'
        'C20'
        'C21'
        'C22'
        'C23'
        'C24'
        'C25'
        'C26'
        'C27'
        'C28'
        'C29'
        'C30'
        'C31'
        'C32'
        'D1'
        'D2'
        'D3'
        'D4'
        'D5'
        'D6'
        'D7'
        'D8'
        'D9'
        'D10'
        'D11'
        'D12'
        'D13'
        'D14'
        'D15'
        'D16'
        'D17'
        'D18'
        'D19'
        'D20'
        'D21'
        'D22'
        'D23'
        'D24'
        'D25'
        'D26'
        'D27'
        'D28'
        'D29'
        'D30'
        'D31'
        'D32'
        };

    biosemi256 = {
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'A8'
        'A9'
        'A10'
        'A11'
        'A12'
        'A13'
        'A14'
        'A15'
        'A16'
        'A17'
        'A18'
        'A19'
        'A20'
        'A21'
        'A22'
        'A23'
        'A24'
        'A25'
        'A26'
        'A27'
        'A28'
        'A29'
        'A30'
        'A31'
        'A32'
        'B1'
        'B2'
        'B3'
        'B4'
        'B5'
        'B6'
        'B7'
        'B8'
        'B9'
        'B10'
        'B11'
        'B12'
        'B13'
        'B14'
        'B15'
        'B16'
        'B17'
        'B18'
        'B19'
        'B20'
        'B21'
        'B22'
        'B23'
        'B24'
        'B25'
        'B26'
        'B27'
        'B28'
        'B29'
        'B30'
        'B31'
        'B32'
        'C1'
        'C2'
        'C3'
        'C4'
        'C5'
        'C6'
        'C7'
        'C8'
        'C9'
        'C10'
        'C11'
        'C12'
        'C13'
        'C14'
        'C15'
        'C16'
        'C17'
        'C18'
        'C19'
        'C20'
        'C21'
        'C22'
        'C23'
        'C24'
        'C25'
        'C26'
        'C27'
        'C28'
        'C29'
        'C30'
        'C31'
        'C32'
        'D1'
        'D2'
        'D3'
        'D4'
        'D5'
        'D6'
        'D7'
        'D8'
        'D9'
        'D10'
        'D11'
        'D12'
        'D13'
        'D14'
        'D15'
        'D16'
        'D17'
        'D18'
        'D19'
        'D20'
        'D21'
        'D22'
        'D23'
        'D24'
        'D25'
        'D26'
        'D27'
        'D28'
        'D29'
        'D30'
        'D31'
        'D32'
        'E1'
        'E2'
        'E3'
        'E4'
        'E5'
        'E6'
        'E7'
        'E8'
        'E9'
        'E10'
        'E11'
        'E12'
        'E13'
        'E14'
        'E15'
        'E16'
        'E17'
        'E18'
        'E19'
        'E20'
        'E21'
        'E22'
        'E23'
        'E24'
        'E25'
        'E26'
        'E27'
        'E28'
        'E29'
        'E30'
        'E31'
        'E32'
        'F1'
        'F2'
        'F3'
        'F4'
        'F5'
        'F6'
        'F7'
        'F8'
        'F9'
        'F10'
        'F11'
        'F12'
        'F13'
        'F14'
        'F15'
        'F16'
        'F17'
        'F18'
        'F19'
        'F20'
        'F21'
        'F22'
        'F23'
        'F24'
        'F25'
        'F26'
        'F27'
        'F28'
        'F29'
        'F30'
        'F31'
        'F32'
        'G1'
        'G2'
        'G3'
        'G4'
        'G5'
        'G6'
        'G7'
        'G8'
        'G9'
        'G10'
        'G11'
        'G12'
        'G13'
        'G14'
        'G15'
        'G16'
        'G17'
        'G18'
        'G19'
        'G20'
        'G21'
        'G22'
        'G23'
        'G24'
        'G25'
        'G26'
        'G27'
        'G28'
        'G29'
        'G30'
        'G31'
        'G32'
        'H1'
        'H2'
        'H3'
        'H4'
        'H5'
        'H6'
        'H7'
        'H8'
        'H9'
        'H10'
        'H11'
        'H12'
        'H13'
        'H14'
        'H15'
        'H16'
        'H17'
        'H18'
        'H19'
        'H20'
        'H21'
        'H22'
        'H23'
        'H24'
        'H25'
        'H26'
        'H27'
        'H28'
        'H29'
        'H30'
        'H31'
        'H32'
        };

end % if isbiosemi

if isegi
    egi256 = cell(256, 1);
    for i = 1:256
        egi256{i} = sprintf('e%d', i);
    end

    % the others are subsets
    egi32  = egi256(1:32);
    egi64  = egi256(1:64);
    egi128 = egi256(1:128);
end % if isegi

% search for the requested definition of channel labels
if exist(type, 'var')
    label = eval(type);
    label = label(:);
else
    error('the requested sensor type is not supported');
end


function varargout = offset(varargin)
% Format
% For getting the value
% dat = offset(obj)
%
% For setting the value
% obj = offset(obj,dat)
% _______________________________________________________________________
% %W% John Ashburner %E%


if nargin==2,
    varargout{1} = asgn(varargin{:});
elseif nargin==1,
    varargout{1} = ref(varargin{:});
else
    error('Wrong number of arguments.');
end;
return;

function dat = ref(obj)
dat = obj.offset;
return;

function obj = asgn(obj,dat)
if isnumeric(dat) && numel(dat)==1 && dat>=0 && rem(dat,1)==0,
    obj.offset = double(dat);
else
    error('"offset" must be a positive integer.');
end;
return;

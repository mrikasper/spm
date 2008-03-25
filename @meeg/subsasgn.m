function this = subsasgn(this,subs,dat)
% Overloaded subsasgn function for meeg objects.
% _________________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Vladimir Litvak
% $Id: subsasgn.m 1243 2008-03-25 23:02:44Z stefan $

if isempty(subs)
    return;
end;

if this.Nsamples == 0
    error('Attempt to assign to a field of an empty meeg object.');
end;

if strcmp(subs(1).type, '.')
    if ismethod(this, subs(1).subs)
        error('meeg method names cannot be used for custom fields');
    else
        if isempty(this.other)
            this.other = struct(subs(1).subs, dat);
        else
            this.other = subsasgn(this.other, subs, dat);
        end
    end
elseif strcmp(subs(1).type, '()')
    if numel(subs)~= 1, error('Expression too complicated');end;
    this.data.y = subsasgn(this.data.y, subs, dat);
else
    error('Unsupported assignment type for meeg.');
end




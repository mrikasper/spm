function d = size(a,varargin)
% overloaded size function for file_array objects.
% _______________________________________________________________________
% %W% John Ashburner %E%

sa  = struct(a);
dim = ones(length(sa),32);
pos = ones(length(sa),32);

for i=1:length(sa)
    sz = sa(i).dim;
    dim(i,1:length(sz)) = sz;
    ps = sa(i).pos;
    pos(i,1:length(ps)) = ps;
end

tmp = pos==1;
for i=1:32
    ind  = find(all(tmp(:,[1:(i-1) (i+1):32]),2));
    d(i) = sum(dim(ind,i));
end;
lim = max(max(find(d~=1)),2);
d   = d(1:lim);

if nargin>1,
	if varargin{1}<=length(d),
		d = d(varargin{1});
	else
		d = 1;
	end;
end;

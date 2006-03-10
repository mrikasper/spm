function [B,Wf]=spm_eeg_robust_averaget(data,ks,FS);

% function to apply robust averaging routine to data sets and return the
% ERP (B) and the weights (Wf)
% ks is the offest of the weighting function the default is 3.


% James Kilner
% $Id: spm_eeg_robust_averaget.m 475 2006-03-10 10:56:05Z james $
if nargin==1
	ks=3;
end

Wf=ones(size(data));
Xs=sparse(repmat(speye(size(data,2)),[size(data,1),1]));
h=1./((1-(diag(Xs*(Xs'*Xs)^-1*Xs'))).^0.5);
h=h(1);

ores=1;
nres=10;
n=0;
B=zeros(1,size(data,1));
while abs(ores-nres)>sqrt(1E-8)
	abs(ores-nres);
	ores=nres;
	n=n+1;

    % New method
    for t=1:size(data,1)
        B(t)=sum(Wf(t,:).*data(t,:))/sum(Wf(t,:));
    end
    sm=gausswin(FS);
    sm=sm/sum(sm);
    mB=mean(B);
    B=conv(sm,B-mean(B));
    B=B(floor(FS/2):end-ceil(FS/2));
    B=B+mB;
	if sum(isnan(B))>0
		break
	end
	if n>100
		break
	end
	res=data-repmat(B',[1,size(data,2)]);
	

	mad=median(abs(res(:)-median(res(:))));	
	res=(res)./mad;
	res=res.*h;	
	res=abs(res)-ks;
	res(res<0)=0;	
	nres=(sum(res(:).^2));
	Wf=(((abs(res)<1) .* (1 - res.^2).^2));
	clear res;

end





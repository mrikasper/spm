function [s_samp,s_bound] = spm_BMS_F_smpl(alpha,lme,alpha0)
% Get sample and lower bound approx. for model evidence p(y|r) in group BMS
% FORMAT [s_samp,s_bound] = spm_BMS_F_smpl(alpha,lme,alpha0)
% 
% See spm_BMS_F.m for details.
%
% Reference:
% Stephan KE, Penny WD, Daunizeau J, Moran RJ, Friston KJ
% Bayesian Model Selection for Group Studies. Neuroimage 2009 46(4):1004-17
%__________________________________________________________________________
% Copyright (C) 2008-2021 Wellcome Centre for Human Neuroimaging

% Will Penny
% $Id: spm_BMS_F_smpl.m 8160 2021-10-01 09:42:13Z guillaume $


% prevent numerical problems 
max_val = log(realmax('double'));
for i=1:size(lme,1)
    lme(i,:) = lme(i,:) - mean(lme(i,:));
    for k = 1:size(lme,2)
        lme(i,k) = sign(lme(i,k)) * min(max_val,abs(lme(i,k)));
    end
end

% Number of samples per alpha bin (0.1)
Nsamp = 1e3;

% Sample from univariate gamma densities then normalise
% (see Dirichlet entry in Wikipedia or Ferguson (1973) Ann. Stat. 1,
% 209-230)
Nk = length(alpha);
for k = 1:Nk
    alpha_samp(:,k) = spm_gamrnd(alpha(k),1,Nsamp,1);
end

Ni = size(lme,1);
for i = 1:Ni
    s_approx(i) = sum((alpha./sum(alpha)).*lme(i,:));
    
    s(i) = 0;
    for n = 1:Nsamp
        s(i) = s(i) + si_fun(alpha_samp(n,:),lme(i,:));
    end
    s(i) = s(i)/Nsamp;
end

s_bound = sum(s_approx);

s_samp = sum(s);


%==========================================================================
function [si] = si_fun(alpha,lme)
% Check a lower bound
% FORMAT [si] = si_fun(alpha,lme)

esi = sum((exp(lme).*alpha)/sum(alpha));
si  = log(esi);

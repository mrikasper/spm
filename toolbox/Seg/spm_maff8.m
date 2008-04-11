function [M,h] = spm_maff8(varargin)
% Affine registration to MNI space using mutual information
% FORMAT M = spm_maff(P,samp,ff,x,tpm,M,regtyp,bg)
% P       - filename or structure handle of image
% x       - cell array of {x1,x2,x3}, where x1 and x2 are
%           co-ordinates (from ndgrid), and x3 is a list of
%           slice numbers to use
% b0      - a cell array of belonging probability images
%           (see spm_load_priors.m).
% MF      - voxel-to-world transform of belonging probability
%           images
% M       - starting estimates
% regtype - regularisation type
%           'mni'   - registration of European brains with MNI space
%           'eastern' - registration of East Asian brains with MNI space
%           'rigid' - rigid(ish)-body registration
%           'subj'  - inter-subject registration
%           'none'  - no regularisation
% ff      - a fudge factor (derived from the one above)
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_maff8.m 1373 2008-04-11 14:24:03Z spm $

[buf,MG,x,ff] = loadbuf(varargin{1:3});
[M,h]         = affreg(buf, MG, x, ff, varargin{4:end});

return;
%_______________________________________________________________________
%_______________________________________________________________________
function [buf,MG,x,ff] = loadbuf(V,samp,ff)
if ischar(V), V = spm_vol(V); end;
d         = V(1).dim(1:3);
vx        = sqrt(sum(V(1).mat(1:3,1:3).^2));
sk        = max([1 1 1],round(samp*[1 1 1]./vx));
[x1,x2,o] = ndgrid(1:sk(1):d(1),1:sk(2):d(2),1);
x3        = 1:sk(3):d(3);

% Fudge Factor - to (approximately) account for
% non-independence of voxels
ff     = max(1,ff^3/prod(sk)/abs(det(V(1).mat(1:3,1:3))));

% Load the image
V         = spm_vol(V);
o         = ones(size(x1));
d         = [size(x1) length(x3)];
g         = zeros(d);
spm_progress_bar('Init',V.dim(3),'Loading volume','Planes loaded');
for i=1:d(3)
    g(:,:,i) = spm_sample_vol(V,x1,x2,o*x3(i),0);
    spm_progress_bar('Set',i);
end;
spm_progress_bar('Clear');

% Convert the image to unsigned bytes
[mn,mx] = spm_minmax(g);
for z=1:length(x3),
    gz         = g(:,:,z);
    buf(z).msk = isfinite(gz) & gz>mn;
    buf(z).nm  = sum(buf(z).msk(:));
    gz         = double(gz(buf(z).msk));
    buf(z).g   = uint8(max(min(round(gz*(255/mx)),255),0));
end;
MG = V.mat;
x  = {x1,x2,x3};
return;
%_______________________________________________________________________
%_______________________________________________________________________
function [M,h0] = affreg(buf,MG,x,ff,tpm,M,regtyp)

kron = inline('spm_krutil(a,b)','a','b');

x1 = x{1};
x2 = x{2};
x3 = x{3};
[mu,isig] = priors(regtyp);
isig      =  isig*ff;
Alpha0    =  isig;
Beta0     = -isig*mu;

db   = size(tpm.dat{1});

sol  = M2P(M);
sol1 = sol;
ll   = -Inf;
spm_chi2_plot('Init','Registering','Log-likelihood','Iteration');

for iter=1:200
    penalty = (sol1-mu)'*isig*(sol1-mu);
    T       = tpm.M\P2M(sol1)*MG;

    %global st
    %st.vols{1}.premul = P2M(sol1);
    %spm_orthviews('Redraw')
    %drawnow

    R       = derivs(tpm.M,sol1,MG);
    y1a     = T(1,1)*x1 + T(1,2)*x2 + T(1,4);
    y2a     = T(2,1)*x1 + T(2,2)*x2 + T(2,4);
    y3a     = T(3,1)*x1 + T(3,2)*x2 + T(3,4);
    h0      = zeros(256,numel(tpm.dat))+eps;
    for i=1:length(x3),
        if ~buf(i).nm, continue; end;
        y1    = y1a(buf(i).msk) + T(1,3)*x3(i);
        y2    = y2a(buf(i).msk) + T(2,3)*x3(i);
        y3    = y3a(buf(i).msk) + T(3,3)*x3(i);

        msk   = y3>=1;
        y1    = y1(msk);
        y2    = y2(msk);
        y3    = y3(msk);
        gm    = buf(i).g(msk);
        b     = spm_sample_priors8(tpm,y1,y2,y3);
        for k=1:size(h0,2),
            h0(:,k) = h0(:,k) + spm_hist(gm,b{k});
        end;
    end;
    h1    = (h0+eps);

   %figure(9); plot(log(h1+1)); drawnow

    ssh   = sum(h1(:));
    krn   = spm_smoothkern(2,(-256:256)',0);
    h1    = conv2(h1,krn,'same');
    h1    = h1/ssh;
    h2    = log2(h1./(sum(h1,2)*sum(h1,1)));
    ll1   = sum(sum(h0.*h2))/ssh - penalty/ssh;
    spm_chi2_plot('Set',ll1);
    if ll1-ll<1e-6, break; end;
    ll    = ll1;
    sol   = sol1;
    Alpha = zeros(12);
    Beta  = zeros(12,1);
    for i=1:length(x3),
        if ~buf(i).nm, continue; end;
        gi    = double(buf(i).g)+1;
        y1    = y1a(buf(i).msk) + T(1,3)*x3(i);
        y2    = y2a(buf(i).msk) + T(2,3)*x3(i);
        y3    = y3a(buf(i).msk) + T(3,3)*x3(i);

        msk   = y3>=1;
        y1    = y1(msk);
        y2    = y2(msk);
        y3    = y3(msk);
        gi    = gi(msk);

        nz    = size(y1,1);
        if nz,
            dmi1  = zeros(nz,1);
            dmi2  = zeros(nz,1);
            dmi3  = zeros(nz,1);
            [b, db1, db2, db3] = spm_sample_priors8(tpm,y1,y2,y3);
            for k=1:size(h0,2),
                tmp  = -h2(gi,k);
                dmi1 = dmi1 + tmp.*db1{k};
                dmi2 = dmi2 + tmp.*db2{k};
                dmi3 = dmi3 + tmp.*db3{k};
            end;
            x1m = x1(buf(i).msk); x1m = x1m(msk);
            x2m = x2(buf(i).msk); x2m = x2m(msk);
            x3m = x3(i);
            A = [dmi1.*x1m dmi2.*x1m dmi3.*x1m...
                 dmi1.*x2m dmi2.*x2m dmi3.*x2m...
                 dmi1 *x3m dmi2 *x3m dmi3 *x3m...
                 dmi1      dmi2      dmi3];
            Alpha = Alpha + A'*A;
            Beta  = Beta  + sum(A,1)';
        end
    end
    drawnow;
    Alpha = R'*Alpha*R;
    Beta  = R'*Beta;

    % Gauss-Newton update
    sol1  = (Alpha+Alpha0)\(Alpha*sol - Beta - Beta0);
end;

spm_chi2_plot('Clear');
M = P2M(sol);
return;
%_______________________________________________________________________
%_______________________________________________________________________
function P = M2P(M)
% Polar decomposition parameterisation of affine transform,
% based on matrix logs
J  = M(1:3,1:3);
V  = sqrtm(J*J');
R  = V\J;

lV = logm(V);
lR = -logm(R);
if sum(sum(imag(lR).^2))>1e-6, error('Rotations by pi are still a problem.'); end;
P       = zeros(12,1);
P(1:3)  = M(1:3,4);
P(4:6)  = lR([2 3 6]);
P(7:12) = lV([1 2 3 5 6 9]);
return;
%_______________________________________________________________________
%_______________________________________________________________________
function M = P2M(P)
% Polar decomposition parameterisation of affine transform,
% based on matrix logs

% Translations
D      = P(1:3);
D      = D(:);

% Rotation part
ind    = [2 3 6];
T      = zeros(3);
T(ind) = -P(4:6);
R      = expm(T-T');

% Symmetric part (zooms and shears)
ind    = [1 2 3 5 6 9];
T      = zeros(3);
T(ind) = P(7:12);
V      = expm(T+T'-diag(diag(T)));

M      = [V*R D ; 0 0 0 1];
return;
%_______________________________________________________________________
%_______________________________________________________________________
function R = derivs(MF,P,MG)
% Numerically compute derivatives of Affine transformation matrix w.r.t.
% changes in the parameters.
R = zeros(12,12);
M0 = MF\P2M(P)*MG;
M0 = M0(1:3,:);
for i=1:12
    dp     = 0.0000001;
    P1     = P;
    P1(i)  = P1(i) + dp;
    M1     = MF\P2M(P1)*MG;
    M1     = M1(1:3,:);
    R(:,i) = (M1(:)-M0(:))/dp;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function [mu,isig] = priors(typ)
% The parameters for this distribution were derived empirically from 227
% scans, that were matched to the ICBM space.

%% Values can be derived by...
%sn = spm_select(Inf,'.*seg_inv_sn.mat$');
%X  = zeros(size(sn,1),12);
%for i=1:size(sn,1),
%    p  = load(deblank(sn(i,:)));
%    M  = p.VF(1).mat*p.Affine/p.VG(1).mat;
%    J  = M(1:3,1:3);
%    V  = sqrtm(J*J');
%    R  = V\J;
%    lV      =  logm(V);
%    lR      = -logm(R);
%    P       = zeros(12,1);
%    P(1:3)  = M(1:3,4);
%    P(4:6)  = lR([2 3 6]);
%    P(7:12) = lV([1 2 3 5 6 9]);
%    X(i,:)  = P';
%end;
%mu   = mean(X(:,7:12));
%XR   = X(:,7:12) - repmat(mu,[size(X,1),1]);
%isig = inv(XR'*XR/(size(X,1)-1))


mu   = zeros(6,1);
isig = zeros(6);
switch deblank(lower(typ))

case 'mni', % For registering with MNI templates...
        mu   = [0.0667 0.0039 0.0008 0.0333 0.0071 0.1071]';
        isig = 1e4 * [
            0.0902   -0.0345   -0.0106   -0.0025   -0.0005   -0.0163
           -0.0345    0.7901    0.3883    0.0041   -0.0103   -0.0116
           -0.0106    0.3883    2.2599    0.0113    0.0396   -0.0060
           -0.0025    0.0041    0.0113    0.0925    0.0471   -0.0440
           -0.0005   -0.0103    0.0396    0.0471    0.2964   -0.0062
           -0.0163   -0.0116   -0.0060   -0.0440   -0.0062    0.1144];

case 'imni', % For registering with MNI templates...
        mu   = -[0.0667 0.0039 0.0008 0.0333 0.0071 0.1071]';
        isig = 1e4 * [
            0.0902   -0.0345   -0.0106   -0.0025   -0.0005   -0.0163
           -0.0345    0.7901    0.3883    0.0041   -0.0103   -0.0116
           -0.0106    0.3883    2.2599    0.0113    0.0396   -0.0060
           -0.0025    0.0041    0.0113    0.0925    0.0471   -0.0440
           -0.0005   -0.0103    0.0396    0.0471    0.2964   -0.0062
           -0.0163   -0.0116   -0.0060   -0.0440   -0.0062    0.1144];

case 'rigid', % Constrained to be almost rigid...
        mu   = zeros(6,1);
        isig = eye(6)*1e8;

case 'subj', % For inter-subject registration...
        mu   = zeros(6,1);
        isig = 1e3 * [
            0.8876    0.0784    0.0784   -0.1749    0.0784   -0.1749
            0.0784    5.3894    0.2655    0.0784    0.2655    0.0784
            0.0784    0.2655    5.3894    0.0784    0.2655    0.0784
           -0.1749    0.0784    0.0784    0.8876    0.0784   -0.1749
            0.0784    0.2655    0.2655    0.0784    5.3894    0.0784
           -0.1749    0.0784    0.0784   -0.1749    0.0784    0.8876];

case 'eastern', % For East Asian brains to MNI...
    mu   = [0.0719   -0.0040   -0.0032    0.1416    0.0601    0.2578]';
    isig = 1e4 * [
        0.0757    0.0220   -0.0224   -0.0049    0.0304   -0.0327
        0.0220    0.3125   -0.1555    0.0280   -0.0012   -0.0284
       -0.0224   -0.1555    1.9727    0.0196   -0.0019    0.0122
       -0.0049    0.0280    0.0196    0.0576   -0.0282   -0.0200
        0.0304   -0.0012   -0.0019   -0.0282    0.2128   -0.0275
       -0.0327   -0.0284    0.0122   -0.0200   -0.0275    0.0511];

case 'none', % No regularisation...
        mu   = zeros(6,1);
        isig = zeros(6);

otherwise
        error(['"' typ '" not recognised as type of regularisation.']);
end;
mu   = [zeros(6,1) ; mu];
isig = [zeros(6,12) ; zeros(6,6) isig];
return;
%_______________________________________________________________________
%_______________________________________________________________________


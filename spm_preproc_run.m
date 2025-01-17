function varargout = spm_preproc_run(job,action)
% Segment a bunch of images
% FORMAT spm_preproc_run(job)
% job.channel(n).vols{m}
% job.channel(n).biasreg
% job.channel(n).biasfwhm
% job.channel(n).write
% job.tissue(k).tpm
% job.tissue(k).ngaus
% job.tissue(k).native
% job.tissue(k).warped
% job.warp.mrf
% job.warp.cleanup
% job.warp.affreg
% job.warp.reg
% job.warp.fwhm
% job.warp.samp
% job.warp.write
% job.warp.bb
% job.warp.vox
% job.iterations
% job.alpha
%
% See the batch interface for a description of the fields.
%
% See also spm_preproc8.m amd spm_preproc_write8.m
%__________________________________________________________________________
% Copyright (C) 2008-2015 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_preproc_run.m 7892 2020-07-10 16:39:18Z john $


SVNid = '$Rev: 7892 $';

if nargin == 1, action = 'run'; end

switch lower(action)
    case 'run'
        spm('FnBanner',mfilename,SVNid);
        varargout{1} = run_job(job);
        fprintf('%-40s: %30s\n','Completed',spm('time'))                %-#
    case 'check'
        varargout{1} = check_job(job);
    case 'vfiles'
        varargout{1} = vfiles_job(job);
    case 'vout'
        varargout{1} = vout_job(job);
    case 'inmem'
        [varargout{1:nargout}] = run_inmem(job);
    otherwise
        error('Unknown argument ("%s").', action);
end


%==========================================================================
% Run
%==========================================================================
function vout = run_job(job)
vout = vout_job(job);
run_seg_multi(job)

%==========================================================================
% Actually Run
%==========================================================================
function [varargout] = run_seg_multi(job)
tpm = strvcat(cat(1,job.tissue(:).tpm));
tpm = spm_load_priors8(tpm);
job = add_missing(job);
nit = job.niterations;
if nit > 1, orig_priors = tpm; end

for iter=1:nit
    for subj=1:numel(job.channel(1).vols)
        fprintf('Segment %s\n',spm_file(job.channel(1).vols{subj},...
            'link','spm_image(''display'',''%s'')'));

        obj = job2obj(job,tpm,subj); 

        if iter==1
            % Initial affine registration.
            obj.Affine = run_affine(obj.image(1),job,tpm);
        else
            % Load results from previous iteration for use with next round of
            % iterations, with the new group-specific tissue probability map.
            [pth,nam]  = fileparts(job.channel(1).vols{subj});
            res        = load(fullfile(pth,[nam '_seg8.mat']));
            obj.Affine = res.Affine;
            obj.Twarp  = res.Twarp;
            obj.Tbias  = res.Tbias;
            if ~isempty(obj.lkp)
                obj.mg = res.mg;
                obj.mn = res.mn;
                obj.vr = res.vr;
            end
        end
 
        % in case masking is needed (e.g. CFM for lesions)
        if isfield(job,'msk')
            obj.msk = job.msk ;
        end

        res = spm_preproc8(obj);

        if ~isfield(job,'savemat') || job.savemat==1
            try
                [pth,nam] = fileparts(job.channel(1).vols{subj});
                save(fullfile(pth,[nam '_seg8.mat']),'-struct','res', spm_get_defaults('mat.format'));
            catch
            end
        end

        if iter==nit
            % Final iteration, so write out the required data.
            tmp1 = [cat(1,job.tissue(:).native) cat(1,job.tissue(:).warped) zeros(numel(job.tissue),4)];
            tmp2 =  cat(1,job.channel(:).write);
            tmp3 = job.warp.write;
            spm_preproc_write8(res,tmp1,tmp2,tmp3,job.warp.mrf,job.warp.cleanup,job.warp.bb,job.warp.vox);
        else
            % Not the final iteration, so compute sufficient statistics for
            % re-estimating the template data.
            N    = numel(job.channel);
            K    = numel(job.tissue);
            tmp1 = zeros(K,8);
            tmp1(:,8) = 1;
            [uu1,uu2,uu3,cls] = spm_preproc_write8(res,tmp1,zeros(N,2),[0 0],job.warp.mrf,...
                                          job.warp.cleanup,job.warp.bb,job.warp.vox);
            M1  = cls{2};
            cls = cls{1};
            if subj==1
                % Sufficient statistics for possible generation of group-specific
                % template data.
                SS = zeros([size(cls{1}),numel(cls)],'single');
            end

            for k=1:K
                SS(:,:,:,k) = SS(:,:,:,k) + cls{k};
            end
        end

    end
    if iter<nit && nit>1
         % Treat the tissue probability maps as Dirichlet priors, and compute the 
         % MAP estimate of group tissue probability map using the sufficient
         % statistics.
         [x1,x2] = ndgrid(1:size(SS,1),1:size(SS,2));
         for i=1:size(SS,3)
             M  = orig_priors.M\M1;
             y1 = M(1,1)*x1 + M(1,2)*x2 + M(1,3)*i + M(1,4);
             y2 = M(2,1)*x1 + M(2,2)*x2 + M(2,3)*i + M(2,4);
             y3 = M(3,1)*x1 + M(3,2)*x2 + M(3,3)*i + M(3,4);
             b  = spm_sample_priors8(orig_priors,y1,y2,y3);
             msk = (y1<1) | (y1>orig_priors.V(1).dim(1)) | ...
                   (y2<1) | (y2>orig_priors.V(1).dim(2)) | ...
                   (y3<1) | (y3>orig_priors.V(1).dim(3));
             for k=1:K
                 bk      = b{k}*job.alpha;
                 bk(msk) = bk(msk)*0.01;
                 SS(:,:,i,k) = SS(:,:,i,k) + bk;
             end
         end
         save SS.mat SS M1
         tpm.M = M1;
         s     = sum(SS,4);
         for k=1:K
             tmp        = SS(:,:,:,k)./s;
             tpm.bg1(k) = mean(mean(tmp(:,:,1)));
             tpm.bg2(k) = mean(mean(tmp(:,:,end)));
             tpm.dat{k} = spm_bsplinc(log(tmp+tpm.tiny),[ones(1,3)*(tpm.deg-1)  0 0 0]);
         end
    end
end

%==========================================================================
% Run in memory for a single subject
%==========================================================================
function [varargout] = run_inmem(job)
tpm = strvcat(cat(1,job.tissue(:).tpm));
tpm = spm_load_priors8(tpm);
job = add_missing(job);

if (numel(job.channel(1).vols)>1), error('This option only does one subject at a time.'); end

obj        = job2obj(job,tpm,1);
obj.Affine = run_affine(obj.image(1),job,tpm);
res        = spm_preproc8(obj);

tmp1 = [false(numel(job.tissue),4) cat(1,job.tissue(:).native) cat(1,job.tissue(:).warped)];
tmp2 =  false(numel(job.channel),2);
tmp3 = [false false];
[varargout{1:nargout}] = spm_preproc_write8(res,tmp1,tmp2,tmp3,job.warp.mrf,job.warp.cleanup,job.warp.bb,job.warp.vox);



function job = add_missing(job)
if ~isfield(job,'iterations'),   job.niterations  =  1; end
if ~isfield(job,'alpha'),        job.alpha        = 12; end
if ~isfield(job.warp,'fwhm'),    job.warp.fwhm    =  1; end
if ~isfield(job.warp,'bb'),      job.warp.bb      =  NaN(2,3); end
if ~isfield(job.warp,'vox'),     job.warp.vox     =  NaN; end
if ~isfield(job.warp,'cleanup'), job.warp.cleanup =  0; end
if ~isfield(job.warp,'mrf'),     job.warp.mrf     =  0; end


function obj = job2obj(job,tpm,subj)
if nargin<3, subj=1; end
images = cell(numel(job.channel),1);
for n=1:numel(job.channel)
    images{n} = job.channel(n).vols{subj};
end
obj.image    = spm_vol(char(images));
spm_check_orientations(obj.image);
obj.fwhm     = job.warp.fwhm;
obj.biasreg  = cat(1,job.channel(:).biasreg);
obj.biasfwhm = cat(1,job.channel(:).biasfwhm);
obj.tpm      = tpm;
obj.lkp      = [];
if all(isfinite(cat(1,job.tissue.ngaus)))
    for k=1:numel(job.tissue)
        obj.lkp = [obj.lkp ones(1,job.tissue(k).ngaus)*k];
    end
end
obj.reg      = job.warp.reg;
obj.samp     = job.warp.samp;


function Affine = run_affine(im,job,tpm)
Affine  = eye(4);
fwhm    = job.warp.fwhm;
affreg  = job.warp.affreg;
samp    = job.warp.samp;

if ~isempty(affreg)
    if isfield(job.warp,'Affine')
        Affine = job.warp.Affine;
    else
        % Sometimes the image origins are poorly specified, in which case it might be worth trying
        % the centre of the field of view instead. The idea here is to run a coarse registration
        % using two sets of starting estimates, and pick the one producing the better objective function.

        % Run using origin at centre of the field of view
       %im1            = obj.image(1);
        im1            = im;
        M              = im1.mat;
        c              = (im1.dim+1)/2;
        im1.mat(1:3,4) = -M(1:3,1:3)*c(:);
        [Affine1,ll1]  = spm_maff8(im1,8,(fwhm+1)*16,tpm,[],affreg); % Closer to rigid
        Affine1        = Affine1*(im1.mat/M);

        % Run using the origin from the header
        im1            = im;
        [Affine2,ll2]  = spm_maff8(im1,8,(fwhm+1)*16,tpm,[],affreg); % Closer to rigid

        % Pick the result with the best fit and use as starting estimate
        if ll1>ll2
            Affine  = Affine1;
        else
            Affine  = Affine2;
        end
    end
    Affine = spm_maff8(im,samp,(fwhm+1)*16,tpm,Affine,affreg); % Closer to rigid
    Affine = spm_maff8(im,samp, fwhm,      tpm,Affine,affreg);
end

%==========================================================================
% Check
%==========================================================================
function msg = check_job(job)
msg = {};
if numel(job.channel) >1
    k = numel(job.channel(1).vols);
    for i=2:numel(job.channel)
        if numel(job.channel(i).vols)~=k
            msg = {['Incompatible number of images in channel ' num2str(i)]};
            break
        end
    end
elseif numel(job.channel)==0
    msg = {'No data'};
end


%==========================================================================
% Vout
%==========================================================================
function vout = vout_job(job)

n     = numel(job.channel(1).vols);
parts = cell(n,4);

channel = struct('biasfield',{},'biascorr',{});
for i=1:numel(job.channel)
    for j=1:n
        [parts{j,:}] = spm_fileparts(job.channel(i).vols{j});
    end
    if job.channel(i).write(1)
        channel(i).biasfield = cell(n,1);
        for j=1:n
            channel(i).biasfield{j} = fullfile(parts{j,1},['BiasField_',parts{j,2},'.nii']);
        end
    end
    if job.channel(i).write(2)
        channel(i).biascorr = cell(n,1);
        for j=1:n
            channel(i).biascorr{j} = fullfile(parts{j,1},['m',parts{j,2},'.nii']);
        end
    end
end

for j=1:n
    [parts{j,:}] = spm_fileparts(job.channel(1).vols{j});
end
param = cell(n,1);
for j=1:n
    param{j} = fullfile(parts{j,1},[parts{j,2},'_seg8.mat']);
end

tiss = struct('c',{},'rc',{},'wc',{},'mwc',{});
for i=1:numel(job.tissue)
    if job.tissue(i).native(1)
        tiss(i).c = cell(n,1);
        for j=1:n
            tiss(i).c{j} = fullfile(parts{j,1},['c',num2str(i),parts{j,2},'.nii']);
        end
    end
    if job.tissue(i).native(2)
        tiss(i).rc = cell(n,1);
        for j=1:n
            tiss(i).rc{j} = fullfile(parts{j,1},['rc',num2str(i),parts{j,2},'.nii']);
        end
    end
    if job.tissue(i).warped(1)
        tiss(i).wc = cell(n,1);
        for j=1:n
            tiss(i).wc{j} = fullfile(parts{j,1},['wc',num2str(i),parts{j,2},'.nii']);
        end
    end
    if job.tissue(i).warped(2)
        tiss(i).mwc = cell(n,1);
        for j=1:n
            tiss(i).mwc{j} = fullfile(parts{j,1},['mwc',num2str(i),parts{j,2},'.nii']);
        end
    end
end

if job.warp.write(1)
    invdef = cell(n,1);
    for j=1:n
        invdef{j} = fullfile(parts{j,1},['iy_',parts{j,2},'.nii']);
    end
else
    invdef = {};
end

if job.warp.write(2)
    fordef = cell(n,1);
    for j=1:n
        fordef{j} = fullfile(parts{j,1},['y_',parts{j,2},'.nii']);
    end
else
    fordef = {};
end

vout  = struct('channel',channel,'tiss',tiss,'param',{param},'invdef',{invdef},'fordef',{fordef});


%==========================================================================
% Vfiles
%==========================================================================
function vf = vfiles_job(job)
vout = vout_job(job);
vf   = vout.param;
if ~isempty(vout.invdef), vf = {vf{:}, vout.invdef{:}}; end
if ~isempty(vout.fordef), vf = {vf{:}, vout.fordef{:}}; end
for i=1:numel(vout.channel)
    if ~isempty(vout.channel(i).biasfield), vf = {vf{:}, vout.channel(i).biasfield{:}}; end
    if ~isempty(vout.channel(i).biascorr),  vf = {vf{:}, vout.channel(i).biascorr{:}};  end
end

for i=1:numel(vout.tiss)
    if ~isempty(vout.tiss(i).c),   vf = {vf{:}, vout.tiss(i).c{:}};   end
    if ~isempty(vout.tiss(i).rc),  vf = {vf{:}, vout.tiss(i).rc{:}};  end
    if ~isempty(vout.tiss(i).wc),  vf = {vf{:}, vout.tiss(i).wc{:}};  end
    if ~isempty(vout.tiss(i).mwc), vf = {vf{:}, vout.tiss(i).mwc{:}}; end
end
vf = reshape(vf,numel(vf),1);

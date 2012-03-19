function spm_est_V(SPM)
% Test routine to evaluate non-sphericity correction (ReML Whitening)
% FORMAT spm_est_V(SPM)
 
% SPM    - structure containing generic analysis details
%__________________________________________________________________________
% Copyright (C) 2008-2011 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_est_V.m 4693 2012-03-16 20:43:17Z karl $
 
% get data and model
%==========================================================================
spm_figure('GetWin','Figure');


% check filenames
%--------------------------------------------------------------------------
SPM.xY.VY = spm_check_filename(SPM.xY.VY);

 
% get data from responsive voxels
%--------------------------------------------------------------------------
N     = 4096;                                  % number of voxels
Vspm  = SPM.xCon(1).Vspm;                      % get first SPM
XYZ   = SPM.xVol.XYZ;
F     = spm_sample_vol(Vspm,XYZ(1,:),XYZ(2,:),XYZ(3,:),0);
[F i] = sort(F,2,'descend');                  
XYZ   = XYZ(:,i(1:N));
rpv   = SPM.xVol.R(end)/SPM.xVol.S;            % resels per voxel
 

% get data and covariance
%--------------------------------------------------------------------------
Y     = spm_get_data(SPM.xY.VY,XYZ);
m     = size(Y,1);
% Y     = spm_conv(randn(m,N),1);                % uncomment for null data
C     = cov(Y');

 
% covariance components (giving a mixture of AR(2) processes)
%==========================================================================
p = 1;
a = [0    0   ;
     p/2  0   ;
     0    p/4 ;
     p/2  p/4 ;
    -p/2  p/4 ;
    -p/2 -p/4];
 
for q = 1:size(a,1)
    for i = 1:q
        Q{q}{i} = spm_Q(a(i,:),m);
    end
end
 
% just consider an i.i.d. model, the current model (almost) and the full
% (9-paramter) model
%--------------------------------------------------------------------------
Q   = Q([1 2 end]);

% remove frequnecy spikes
%--------------------------------------------------------------------------
X     = SPM.xX.X;
try
    X = [X SPM.xX.K.X0];
end

% Residual forming matrix
%--------------------------------------------------------------------------
R = speye(m,m) - X*spm_pinv(X);
S = spm_sqrtm(C);
s = fft(full(R*S));
g = sum(abs(s).^2,2);

% Add frequencies to confounds
%--------------------------------------------------------------------------
[i g] = sort(g(1:fix(m/2)),'descend');
X0    = [];
for i = 1:4
    X0 = [X0 real(fft(full(sparse(g(i),1,1,m,1))))];
    X0 = [X0 imag(fft(full(sparse(g(i),1,1,m,1))))];
end
SPM.xX.K.X0 = [SPM.xX.K.X0 X0]; 


 
% perform null t-tests
%==========================================================================
t     = -4:1/8:4;                   % range of t-values to plot
c     = 4;                          % number of contrasts per ReML
for k = 1:8                         % number of ReML 
    
    % get design and augment with drift terms
    %----------------------------------------------------------------------
    X     = SPM.xX.X;
    try
        X = [X SPM.xX.K.X0];
    end
    
    % add simulated effects
    %----------------------------------------------------------------------
    E     = spm_conv(randn(size(X,1),c),8,0);
    X     = [E X];
    
    % Residual forming matrix
    %----------------------------------------------------------------------
    [m n] = size(X);
    R     = speye(m,m) - X*spm_pinv(X);   
    for q = 1:length(Q)
        
        % ReML
        %------------------------------------------------------------------
        V      = spm_reml(C,X,Q{q});

        % save
        %------------------------------------------------------------------
        W      = spm_sqrtm(spm_inv(V));
        DF     = trace(R*V)^2/trace(R*V*R*V);
        
        % empirical t-distribution
        %------------------------------------------------------------------
        for i = 1:c
            [T,df] = spm_ancova(W*X,[],W*Y,sparse(i,1,1,n,1));
            try
                Tpdf{q} = Tpdf{q} + hist(T,t);
            catch
                Tpdf{q} = hist(T,t);
            end
        end
        
    end
    
    % plot FPR above a t-threshold u = 3
    %----------------------------------------------------------------------
    subplot(2,2,4)
    TPDF  = spm_Tpdf(t,df(2));
    TPDF  = sum(Tpdf{1})*TPDF/sum(TPDF);
    u     = find(abs(t) > 3);
    FPR   = sum(TPDF(u));
    for q = 1:length(Tpdf)
        fpr(q)  = sum(Tpdf{q}(u));
    end
    
    % plot in terms of resels (under Poisson assumptions)
    %----------------------------------------------------------------------
    spm_plot_ci(fpr(:)*rpv,fpr(:)*rpv), hold on
    plot([0 length(Tpdf)],[FPR FPR]*rpv,'LineWidth',4), hold off
    title('False positive rates u = 3','FontSize',16)
    ylabel('resolution elements')
    axis square
    
    
    % null distributions
    %--------------------------------------------------------------------------
    subplot(2,2,3)
    semilogy(t,Tpdf{end},'k',t,TPDF,'k-.',t,Tpdf{1},'r')
    title('t-distributions','FontSize',16)
    axis square
    legend({'whitened � empirical','true','unwhitened - empirical'})
    drawnow
    
end
 
 
% results
%==========================================================================
spm_figure('GetWin','Figure');
  
 
% Fourier transforms
%--------------------------------------------------------------------------
S = spm_sqrtm(C);
s = fft(full(R));
g = sum(abs(s).^2,2);
s = fft(full(R*S));
g = [g sum(abs(s).^2,2)];
s = fft(full(R*W*S));
g = [g sum(abs(s).^2,2)];
 
subplot(2,2,1)
i    = fix(2:m/2);
plot(g(i,:))
title('spectral density','FontSize',16)
axis square
legend({'ideal','unwhitened','whitened'})
 
% correlation functions
%--------------------------------------------------------------------------
for i = 1:size(g,2);
    f      = ifft(g(:,i));
    r(:,i) = real(fftshift(f));
end
subplot(2,2,2)
i  = (-32:32) + fix(m/2);
plot(r(i,:))
title('correlation function','FontSize',16)
axis square
 
 
disp(DF);
 
return
 
 
% stationarity analysis
%==========================================================================
X     = SPM.xX.X;
try
    X = [X SPM.xX.K.X0];
end
 
% Residual forming matrix
%--------------------------------------------------------------------------
[m n] = size(X);
R     = speye(m,m) - X*pinv(X);
for i = 1:8
    
    % ReML
    %----------------------------------------------------------------------
    C     = cov(Y(:,1:(512*i))');
    
    [V h] = spm_reml(C,X,Q{end});
    
    % save
    %----------------------------------------------------------------------
    df(i)  = trace(R*V)^2/trace(R*V*R*V);
    
end
 
% Stationarity
%--------------------------------------------------------------------------
subplot(2,2,1)
bar(df)
title('effective df','FontSize',16)
axis square
drawnow
% Demo routine for local field potoential models
%==========================================================================

clear global
clear

% number of regions in coupled map lattice
%--------------------------------------------------------------------------
n     = 1;

% specifc network (connections)
%--------------------------------------------------------------------------
if n > 1
A{1}  = diag(ones(n - 1,1),-1);
else
    A{1}  = 0;
end
A{2}  = A{1}';
A{3}  = sparse(n,n);
B{1}  = sparse(n,n);
C     = sparse(1,1,1,n,1);

% mixture of regions subtending LFP(EEG)
%--------------------------------------------------------------------------
L     = ones(1,n);

% mixture of states subtending LFP(EEG)
%--------------------------------------------------------------------------
H     = sparse(9,1,1,13,1);

% get priors
%--------------------------------------------------------------------------
[pE,pC] = spm_lfp_priors(A,B,C,L,H);

% create LFP model
%--------------------------------------------------------------------------
global M

[l n] = size(L);

M.f   = 'spm_fx_lfp';
M.g   = 'spm_gx_lfp';
M.x   = sparse(n*13,1);
M.pE  = pE;
M.pC  = pC;
M.m   = length(B);
M.n   = size(M.x,1);
M.l   = l;
M.IS  = 'spm_int';

% create BOLD model
%--------------------------------------------------------------------------
[hE,hC] = spm_hdm_priors(1,5);
hE(end) = 1;

% model
%--------------------------------------------------------------------------
clear H
H.f     = 'spm_fx_HRF';
H.g     = 'spm_lambda_HRF';
H.x     = [0 1 1 1]';
H.pE    = hE;    
H.pC    = hC;
H.m     = 1;
H.n     = 4;
H.l     = 1;

% for Andre and Jean
%==========================================================================

% augment and bi-linearise
%--------------------------------------------------------------------------
[M0,M1,L1] = spm_bireduce(M,M.pE);

% compute kernels (over 64 ms)
%--------------------------------------------------------------------------
N          = 64;
dt         = 1/1000;
t          = [1:N]*dt*1000;
[K0,K1,K2] = spm_kernels(M0,M1,L1,N,dt);

subplot(2,1,1)
plot(t,K1)
axis square
xlabel('time (ms)')

subplot(2,1,2)
imagesc(t,t,K2(1:64,1:64))
axis square
xlabel('time (ms)')


% Integrate system to see response
%--------------------------------------------------------------------------
N     = 2048;
U.dt  = 8/1000;
U.u   = sparse(128:512,1,1/U.dt,N,M.m) + randn(N,M.m)/U.dt/8;
t     = [1:N]*U.dt;
LFP   = spm_int(pE,M,U);


% LFP
%--------------------------------------------------------------------------
subplot(3,1,1)
plot(t,LFP)
axis square
xlabel('time (s)')

% time-frequency
%--------------------------------------------------------------------------
w     = [1 8]./(256*dt); 
subplot(3,1,2)
imagesc(t,w,abs(spm_wft(LFP,1:1/16:8,256)).^2);
axis square xy
xlabel('time (s)')

% Use response to drive a hemodynamic model
%--------------------------------------------------------------------------
U.u   = LFP;
BOLD  = spm_int(hE,H,U);

subplot(3,1,3)
plot(t,BOLD)
axis square
xlabel('time (s)')


% Stability analysis (over excitatory and inhibitory time constants)
%--------------------------------------------------------------------------
p     = [-8:16]/8;
np    = length(p);
HZ    = sparse(np,np);
for i = 1:np
    for j = 1:np
        P        = M.pE;
        P.T(:,1) = P.T(:,1) + p(i);
        P.T(:,2) = P.T(:,2) + p(j);
        S        = eig(full(spm_bireduce(M,P)));
        LE(i,j)  = max(real(S));
        S        = S(abs(imag(S)) > 2*2*pi & abs(imag(S)) < 64*2*pi);
        try
            [k l]    = max(real(S));
            HZ(i,j)  = imag(S(l))/(2*pi);
        end
    end
end

p  = exp([p(1) p(end)]);
subplot(2,2,1)
imagesc(p,p,LE)
axis square xy
xlabel('inbitory time constant')
ylabel('excitatory time constant')
title('stability')

subplot(2,2,2)
contour(LE,[1 1])
axis square
xlabel('inbitory time constant')
ylabel('excitatory time constant')
title('stability')

subplot(2,2,3)
imagesc(p,p,HZ);
axis square xy
xlabel('inbitory time constant')
ylabel('excitatory time constant')
title('Frequency')

subplot(2,2,4)
contour(full(HZ),[4 8 14 24 34]);
axis square
xlabel('inbitory time constant')
ylabel('excitatory time constant')
title('Frequency')



% for Rosalyn
%==========================================================================

% compute transfer functions
%--------------------------------------------------------------------------
N          = 128;
dt         = 8/1000;
t          = 1:(N/2);
w          = (t - 1)/(N*dt);
[M0,M1,L1] = spm_bireduce(M,M.pE);
[K0,K1]    = spm_kernels(M0,M1,L1,N,dt);
S          = fft(K1);
G          = abs(S(t,:)).^2;

subplot(2,1,1)
plot(w,G)
axis square
xlabel('frequency {Hz}')

% and back to Andre
% compute transfer functions for different levels of I-I
%--------------------------------------------------------------------------
p       = log([1:35]/4);
pE      = M.pE;
pE.T(2) = log(2);
for i = 1:length(p)
    P          = pE;
    P.G(:,5)   = P.G(:,5) + p(i);
    [M0,M1,L1] = spm_bireduce(M,P);
    [K0,K1]    = spm_kernels(M0,M1,L1,N,dt);
    S          = fft(K1);
    GW(:,i)    = abs(S(t,:)).^2;
end

subplot(2,1,1)
imagesc(w,exp(p),GW')
xlabel('Frequency')
ylabel('I-I scaling')

subplot(2,1,2)
plot(w,GW')
xlabel('Frequency')
ylabel('g(w)')


% to Rosalyn again; inversion (in frequency space)
%==========================================================================
[M0,M1,L1] = spm_bireduce(M,M.pE);
[K0,K1]    = spm_kernels(M0,M1,L1,N,dt);
S          = fft(K1);
G          = abs(S(t,:)).^2;


% target density (e.g., emprical data)
%--------------------------------------------------------------------------
hz         = 8;
y          = G + max(G)*exp(-(w(:) - hz).^2/16);
Y.y        = log(y) + randn(64,1)/8;
Y.dt       = w(2) - w(1);
Y.X0       = ones(length(y),1);

% specify prediction model (i.e. replace intgrator with a Hz predictor
%--------------------------------------------------------------------------
M.IS       = 'spm_lfp_prediction';

% invert
%--------------------------------------------------------------------------
[Ep,Cp,S,F] = spm_nlsi_GN(M,[],Y);




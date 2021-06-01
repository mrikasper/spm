function DEM_demo_psychosis
% This demonstration routine illustrates the use of attractors in dynamical
% systems theory to explain fluctuations in longitudinal data, such as
% symptom scores. The generative model is based upon a Lorenz system that
% features a number of attractors; namely, fixed point attractors
% (modelling conditions that resolve), quasi-periodic attractors that can
% model cyclothymic conditions, and chaotic attractors that show a more
% itinerant time course. As with the model based upon stochastic chaos, the
% Lorenz system generates fluctuations in a low dimensional space of
% physiological variables that, in turn, generate psychological states,
% which are then thresholded to generate symptom scores. In this example,
% there are three physiological states, two psychological states and two
% kinds of symptom score (generated by using a soft threshold function of
% psychological states). The parameters of this model range from the
% parameters of the dynamical attractor that determine the underlying time
% course of some synthetic (e.g., schizoaffective) disorder through to the
% parameters of the likelihood mapping to symptom scores – and the initial
% states.

% The demonstration here is very elemental and just illustrates how a
% multi-start scheme can recover key parameters and that these are
% sufficient to differentiate between subjects, when used as computational
% biomarkers or phenotypes. The recovery or inversion of these parameters
% is much more robust in this example, relative to the stochastic chaos
% example using variational filtering. This is because the only unknowns
% are the parameters determining the dynamics of the underlying
% pathophysiology (and, implicitly, psychopathology). In other words, using
% a generative model based upon deterministic dynamics makes the problem
% much easier (cf, the difference between deterministic dynamic causal
% modelling and stochastic dynamic causal modelling).
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: DEM_demo_ontology.m 6511 2015-08-02 15:05:41Z karl $
 
 
%% Set up the generative model
%==========================================================================
rng('default')

% create some synthetic time courses to model
%--------------------------------------------------------------------------
R  = zeros(148,2);
R( 1:18,1)  = 1;
R(42:50,1)  = 1;
R(82:92,1)  = 1;
R( 1:20,2)  = 1;
R(80:end,2) = 1;
Y           = R;

% dynamics and parameters of a Lorentz system (with Jacobian)
%==========================================================================
% dxdt = f(x,v)             Underlying dynamics with exogenous inputs        
% y    = h(g(x)) + e        Observer model generating observed data
%--------------------------------------------------------------------------

% level 1: Thresholding function (M.h) that converts continuous states of
% psychopathology into discrete scores (here between 0 and 1) with
% thresholds parameterised by P.u. This function can be changed to apply
% multiple thresholds to generate discrete scales of the sort found in
% clinical instruments.
%--------------------------------------------------------------------------
M.h  = @(x,P)spm_phi([x(:,1) - P.u(1), x(:,2) - P.u(2)]*8);
 
% level 2: the level that generates latent causes v = g(x) from
% (pathophysiological) states (x) that are subject to interventions (v).
% The first equation (M.f) models the dynamics or flow of underlying
% pathophysiology using a Lorentz system, while the second equation (M.d)
% extracts a subset of physiological states and mixes them to generate the
% psychological states. The parameters of these functions determine the
% underlying dynamics of the disease (P.A) and its psychopathological
% manifestation (P.B)
%--------------------------------------------------------------------------
M.f  = @(x,v,P,M)[-P.A(1) P.A(1) 0; ((1 - v*P.A(3))*P.A(2) - x(3)) -1 0; x(2) 0 -8/3]*x/P.t;
M.d  = @(x,P) x*P.B/16;

% level 3: the level that perturbed the physiological dynamics by
% intervening on the parameters governing flow. These interventions or
% exogenous inputs could be regarded as life events or pharmacological
% interventions. These interventions (M.v) are smooth and  fluctuating
% changes that are parameterised with the coefficients of a discrete cosine
% function of time (P.v).
%--------------------------------------------------------------------------
M.v  = @(T,P) spm_dctmtx(T,numel(P.C))*P.C(:);

% Having established the structure of the generative model we can now
% specify the prior expectations over the requisite parameters; including
% the overall rate at which the dynamics are expressed (P.t). Here, P.u
% parameterises the initial states at the beginning of the timeseries.
%--------------------------------------------------------------------------
pE.A = [10 16 1];                      % parameters of pathophysiology
pE.B = [2 0;0 1;0 0];                  % mapping to psychopathology
pE.C = [0 0 0 0 0 0 0 0];              % parameters of perturbations
pE.x = [16; 4; 32];                    % initial physiological states
pE.u = [1,1];                          % threshold for (two) outcomes
pE.t = 128;                            % time constant of dynamics

% The priors are completed by specifying the prior covariance, that
% determines which parameters are fixed and which are unknown and need to
% be estimated
%--------------------------------------------------------------------------
pC.A = spm_zeros(pE.A) + 1;
pC.B = spm_zeros(pE.B) + 1;
pC.C = spm_zeros(pE.C) + 1/32;
pC.x = spm_zeros(pE.x) + 4;
pC.u = spm_zeros(pE.u) + 0;
pC.t = 1;

% model inversion with Variational Laplace
%==========================================================================
% In the first section of this demo, we will generate some data and
% illustrate the recovery of the parameters used to generate the data using
% variational Laplace. The key parameter we will focus on is the second
% parameter of the flow, known in physics as the Rayleigh parameter. This
% parameter determines whether the dynamics have a fixed point attractor or
% a periodic attractor (or a chaotic attractor). because this generative
% model assumes Gaussian fluctuations about the predicted data, it can be
% summarised with a single function of the parameters that generates a
% timeseries, here, the subroutine spm_psychosis_gen.m
%
% There are two special aspects to this inversion. First, because we are
% dealing with a highly non-linear system, there can be many local maxima.
% This can be resolved using a multi-start algorithm. In other words, by
% initialising the priors in the basins of attraction of all local
% minimaone can  identify the model with the greatest free energy or
% marginal likelihood, which corresponds to the global maxima. Second,
% because this inversion scheme uses gradient descent, it is necessary to
% use a particular kind of feature selection (M.FS) function that converts
% variations in the timing of the discrete changes in scores into
% variations in amplitude. This smoothing is done automatically in the same
% way that a link function converts a general linear model into a
% generalised linear model.

% length of trajectory (e.g., symptom score timeseries)
%--------------------------------------------------------------------------
T      = size(Y,1);                % number of assessments

% model specification
%==========================================================================
M.Nmax = 32;                       % maximum number of iterations
M.G    = @spm_psychosis_gen;       % generative function
M.FS   = @(Y)spm_conv(Y,16,0);     % feature selection  (link function)
M.pE   = pE;                       % prior expectations (parameters)
M.pC   = diag(spm_vec(pC));        % prior covariances  (parameters)
M.hE   = 2;                        % prior expectation  (log-precision)
M.hC   = 1/64;                     % prior covariances  (log-precision)
U      = zeros(T,1);               % Prior expectation of fluctuations


% multi-start inversion with initial parameters sampled from prior here, we
% will try to fit the empirical data above and use the best priors to
% generate synthetic data (with different Rayleigh parameters) for further
% analysis
%==========================================================================
F     = -Inf;
for i = 1:16
    
    % initialise parameters
    %----------------------------------------------------------------------
    dP           = spm_sqrtm(M.pC)*randn(spm_length(M.pE))/8;
    M.P          = spm_unvec(spm_vec(M.pE) + dP,M.pE);
    [ep,cp,eh,f] = spm_nlsi_GN(M,U,Y);
    
    % update priors if model evidence has increased
    %----------------------------------------------------------------------
    if f > F
        F    = f;
        M.pE = ep;
    end
end

% generate synthetic symptom scores with a particular Rayleigh parameter
%==========================================================================
P      = M.pE;                     % start with prior expectations 
Y      = spm_psychosis_gen(P,M,U); % generate a synthetic timeseries

% fix most prior covariances for numerical convenience
%--------------------------------------------------------------------------
pC.A = spm_zeros(pE.A) + 0;
pC.B = spm_zeros(pE.B) + 0;
pC.C = spm_zeros(pE.C) + 0;
pC.x = spm_zeros(pE.x) + 0;
pC.u = spm_zeros(pE.u) + 0;
pC.t = 0;

pC.A(2) = 1;

% multi-start inversion with Variational Laplace
%--------------------------------------------------------------------------
M.pC  = diag(spm_vec(pC));         % prior covariances  (parameters)
pA    = 8:4:24;                    % initial values of Rayleigh parameter
F     = -Inf;
for i = 1:numel(pA)
    
    % initialise parameters (i.e., prior expectations) and invert
    %----------------------------------------------------------------------
    M.pE.A(2)    = pA(i);
    [ep,cp,eh,f] = spm_nlsi_GN(M,U,Y);
    
    % retain posteriors if model evidence has increased
    %----------------------------------------------------------------------
    if f > F
        F      = f;
        DCM.Ep = ep;
        DCM.Cp = cp;
        DCM.Eh = eh;
        DCM.F  = F;
    end
end

% illustrate results
%--------------------------------------------------------------------------
DCM.M  = M;
DCM.Y  = Y;
DCM.U  = U;
DCM.P  = P;
spm_DCM_plot(DCM)



%% repeat for a group subjects with random parametric effects
%==========================================================================
% In this section, we will repeat the above but for a group of subjects
% each with a unique parameter. The idea here is to illustrate the
% identifiability of this generative model by ensuring the parameters used
% to generate the data can be recovered, approximately, from those data


% set up the simulated group study
%--------------------------------------------------------------------------
M.nograph = 1;                           % suppress inversion graphics

n     = 16;                              % number of subjects
pP    = zeros(n,1);                      % values of Rayleigh parameter
qP    = zeros(n,1);                      % posterior estimates
pY    = [];                              % true symptom scores
qY    = [];                              % predicted scores
for j = 1:n
    
    % generate symptom scores with this subject's Rayleigh parameter
    %----------------------------------------------------------------------
    P      = M.pE;                       % start with prior expectations
    P.A(2) = 16 + rand*2;                % specify a random subject effect
    Y      = spm_psychosis_gen(P,M,U);   % generate timeseries
    
    % model inversion with Variational Laplace
    %----------------------------------------------------------------------
    Ep     = spm_nlsi_GN(M,U,Y);

    % generate predicted symptom scores using posterior expectations
    %----------------------------------------------------------------------
    y     = spm_psychosis_gen(Ep,M,U);
    pY    = [pY Y];
    qY    = [qY y];
    pP(j) =  P.A(2);
    qP(j) = Ep.A(2);
    
    % illustrate true and inferred symptom scores and parameters
    %----------------------------------------------------------------------
    spm_figure('GetWin','Figure 2'); clf
    
    subplot(2,2,1)
    imagesc(pY')
    xlabel('time points')
    ylabel('subjects and symptom scores')
    title('Synthetic symptom scores','FontSize',16), axis square
    
    subplot(2,2,2)
    imagesc(qY')
    xlabel('time points')
    ylabel('subjects and symptom scores')
    title('Predicted symptom scores','FontSize',16), axis square
    
    subplot(2,1,2)
    plot(pP,qP,'.','MarkerSize',32), hold on, plot(pP,pP,':'), hold off
    xlabel('parameter used to generate data')
    ylabel('posterior parameter estimate')
    title('True and estimated parameters','FontSize',16), axis square
    drawnow

end

function [y,s,x] = spm_psychosis_gen(P,M,U)
% FORMAT [y,s,x] = spm_psychosis_gen(P,M,U)

% generate symptom scores from underlying physiological dynamics
%--------------------------------------------------------------------------
T    = size(U,1);                    % number of time points

M.x  = P.x;                          % initial physiological states
U    = M.v(T,P);                     % fluctuations
x    = spm_int_J(P,M,U);             % integrate trajectory over time
s    = M.d(x,P);                     % generate psychological states
y    = M.h(s,P);                     % and threshold symptom scores

return

% plotting sub function
%==========================================================================
function spm_DCM_plot(DCM)
 
% generate true and posterior expectations
%--------------------------------------------------------------------------
[Y,S,X]  = spm_psychosis_gen(DCM.P ,DCM.M,DCM.U);
[y,s,x]  = spm_psychosis_gen(DCM.Ep,DCM.M,DCM.U);

% plot symptoms, psychopathology and pathophysiology
%--------------------------------------------------------------------------
subplot(3,2,1), plot(Y,':'); hold on, set(gca,'ColorOrderIndex',1)
plot(y), hold off
title('Symptoms scores','fontsize',16), xlabel('time')
subplot(3,2,3), plot(S,':'); hold on, set(gca,'ColorOrderIndex',1)
plot(s), hold off
title('Latent psychopathology','fontsize',16), xlabel('time')
subplot(3,2,4), plot(X,':'); hold on, set(gca,'ColorOrderIndex',1), 
plot(x), hold off
title('Latent pathophysiology','fontsize',16), xlabel('time')

% supplement with trajectories in phase space
%--------------------------------------------------------------------------
subplot(3,2,5), cla
plot(S(:,1),S(:,2)), hold on;
plot(s(:,1),s(:,2))
title('Psychopathology','fontsize',16), box off
legend({'true','inferred'})

subplot(3,2,6), cla
plot3(X(:,1),X(:,2),X(:,3)), hold on;
plot3(x(:,1),x(:,2),x(:,3))
title('Pathophysiology','fontsize',16), box off

% supplement with image format of symptom scores
%--------------------------------------------------------------------------
subplot(6,2,2), imagesc(Y')
title('Observed and predicted scores','fontsize',16)
subplot(6,2,4), imagesc(y'), xlabel('time'), drawnow




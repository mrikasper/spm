function spm_MDP_VB_trial(MDP,gf,gg)
% auxiliary plotting routine for spm_MDP_VB - single trial
% FORMAT spm_MDP_VB_trial(MDP,[f,g])
%
% MDP.P(M,T)      - probability of emitting action 1,...,M at time 1,...,T
% MDP.X           - conditional expectations over hidden states
% MDP.R           - conditional expectations over policies
% MDP.o           - outcomes at time 1,...,T
% MDP.s           - states at time 1,...,T
% MDP.u           - action at time 1,...,T
%
% MDP.un  = un;   - simulated neuronal encoding of hidden states
% MDP.xn  = Xn;   - simulated neuronal encoding of policies
% MDP.wn  = wn;   - simulated neuronal encoding of precision
% MDP.da  = dn;   - simulated dopamine responses (deconvolved)
%
% [f,g]           - factors and outcomes to plot [Default: first 3]
%
% please see spm_MDP_VB
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_MDP_VB_trial.m 8172 2021-10-25 10:20:42Z karl $

% graphics
%==========================================================================
MDP   = spm_MDP_check(MDP); clf

% numbers of transitions, policies and states
%--------------------------------------------------------------------------
if iscell(MDP.X)
    Nf = numel(MDP.B);                 % number of hidden state factors
    Ng = numel(MDP.A);                 % number of outcome factors
    X  = MDP.X;
    C  = MDP.C;
    for f = 1:Nf
        Nu(f) = size(MDP.B{f},3) > 1;
    end
else
    Nf = 1;
    Ng = 1;
    Nu = 1;
    X  = {MDP.X};
    C  = {MDP.C};
end

% factors and outcomes to plot
%--------------------------------------------------------------------------
maxg  = 3;
if nargin < 2, gf = 1:min(Nf,maxg); end
if nargin < 3, gg = 1:min(Ng,maxg); end
nf    = numel(gf);
ng    = numel(gg);

% posterior beliefs about hidden states
%--------------------------------------------------------------------------
for f = 1:nf
    subplot(3*nf,2,(f - 1)*2 + 1)
    image(64*(1 - X{gf(f)})), hold on
    a = axis;
    if size(X{gf(f)},1) > 128
        
        spm_spy(X{gf(f)},16,1)
        ;
    end
    plot(MDP.s(gf(f),:),'.c','MarkerSize',16), axis(a), hold off
    if f < 2
        title(sprintf('Hidden states - %s',MDP.label.factor{gf(f)}));
    else
        title(MDP.label.factor{gf(f)});
    end
    
    set(gca,'XTickLabel',{});
    set(gca,'XTick',1:size(X{1},2)); 
    
    YTickLabel = MDP.label.name{gf(f)};
    if numel(YTickLabel) > 8
        i = linspace(1,numel(YTickLabel),8);
        YTickLabel = YTickLabel(round(i));
    else
        i = 1:numel(YTickLabel);
    end
    set(gca,'YTick',i);
    set(gca,'YTickLabel',YTickLabel);
end

% posterior beliefs about control states
%--------------------------------------------------------------------------
Nu     = find(Nu);
Np     = length(Nu);
for f  = 1:Np
    subplot(3*Np,2,f*2)
    P  = MDP.P;
    if Nf > 1
        ind     = 1:Nf;
        for dim = 1:Nf
            if dim ~= ind(Nu(f))
                P = sum(P,dim);
            end
        end
        P = squeeze(P);
    end
    
    % display
    %----------------------------------------------------------------------
    image(64*(1 - P)), hold on
    plot(MDP.u(Nu(f),:),'.c','MarkerSize',16), hold off
    if f < 2
        title(sprintf('Action - %s',MDP.label.factor{Nu(f)}));
    else
        title(MDP.label.factor{Nu(f)});
    end
    set(gca,'XTickLabel',{});
    set(gca,'XTick',1:size(X{1},2));
    
    YTickLabel = MDP.label.action{Nu(f)};
    if numel(YTickLabel) > 8
        i = round(linspace(1,numel(YTickLabel),8));
        YTickLabel = YTickLabel(i);
    else
        i = 1:numel(YTickLabel);
    end
    set(gca,'YTick',i);
    set(gca,'YTickLabel',YTickLabel);
    
    % policies
    %----------------------------------------------------------------------
    subplot(3*Np,2,(Np + f - 1)*2 + 1)
    imagesc(MDP.V(:,:,Nu(f))')
    if f < 2
        title(sprintf('Allowable policies - %s',MDP.label.factor{Nu(f)}));
    else
        title(MDP.label.factor{Nu(f)});
    end
    if f < Np
        set(gca,'XTickLabel',{});
    end
    set(gca,'XTick',1:size(X{1},2) - 1);
    set(gca,'YTickLabel',{});
    ylabel('policy')
    
end

% expectations over policies
%--------------------------------------------------------------------------
try
    subplot(3,2,4)
    image(64*(1 - MDP.un))
    title('Posterior probability')
    ylabel('policy')
    xlabel('updates')
end

% sample (observation) and preferences
%--------------------------------------------------------------------------
for g  = 1:ng
    
    subplot(3*ng,2,(2*ng + g - 1)*2 + 1), hold off
    if size(C{gg(g)},1) > 128
        spm_spy(C{gg(g)},16,1), hold on
    else
        imagesc(1 - C{gg(g)}),  hold on
    end
    plot(MDP.o(gg(g),:),'.c','MarkerSize',16), hold off
    if g < 2
        title(sprintf('Outcomes and preferences - %s',MDP.label.modality{gg(g)}));
    else
        title(MDP.label.modality{gg(g)});
    end
    if g == ng
        xlabel('time');
    else
        set(gca,'XTickLabel',{});
    end
    set(gca,'XTick',1:size(X{1},2))

    YTickLabel = MDP.label.outcome{gg(g)};
    if numel(YTickLabel) > 8
        i = round(linspace(1,numel(YTickLabel),8));
        YTickLabel = YTickLabel(i);
    else
        i = 1:numel(YTickLabel);
    end
    set(gca,'YTick',i);
    set(gca,'YTickLabel',YTickLabel);
    
end

% expected precision
%--------------------------------------------------------------------------
if size(MDP.dn,2) > 0
    subplot(3,2,6)
    if size(MDP.dn,2) > 1
        plot(MDP.dn,'r:'),   hold on, plot(MDP.wn,'c','LineWidth',2), hold off
    else
        bar(MDP.dn,1.1,'k'), hold on, plot(MDP.wn,'c','LineWidth',2), hold off
    end
    title('Expected precision (dopamine)')
    xlabel('updates'), ylabel('precision'), spm_axis tight, box off
end
drawnow

% Action-selection for Model-Based Reinforcement Learning.
% (C) Ivilin Stoianov, ISTC-CNR, Italy. Please, cite:
% Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis.  Plos Computational Biology

% Requires a model (m), target (ct) and current state (st).
function A=mbrl_actionselection(M,ct,st)
% Pm(s'|s,a) is the conditional distribution describing the probability to land to state s' following the transition (s,a)->s' (i.e., the model of the world)
% Pr(r |c,s) is the conditional distribution of obtaining either non-reward(r=0) or reward(r=1) if we are at state s and the target is c

switch M.actpolicy
    
case 1 % Full distribution, 1-step
 % P(r=1|s,c,a:) = P(r=1|s':,c)*P(s':|s,a:)
 % To infer the action, clamp r=2, state=st, target=ct and get the action that brings to max reward. 
 pA=reshape(M.Pr(2,ct,:),1,M.nCAT)*squeeze(M.Pm(:,st,:));
 swlen=1; swcer=acertainty(pA);  % Certainty of the action to be taken
  
case 3 % Sweeps of length based on discriminative uncertainty
    
 pA=zeros(1,M.nA,'single'); stX=pA;     % Collect the probability to obtain reward following each action a
 swcer=zeros(1,M.lsweepA,'single');    % Collect the certainty of the choice of aciton
 % The 1st-step of all sweeps
 for iA=1:M.nA                          % Init the sweep of each action
   [~,stX(iA)]=max(M.Pm(:,st,iA));      % Apply the model to find the state after taking action iA (the 1st action iA of the sweep is imposed and not selected)
   pA(iA)=M.Pr(2,ct,stX(iA));           % The reward at the state where we had landed after taking the action iA
 end
 swcer(1)=acertainty(pA);
 
 % Follow sweeps that accumulate evidence for choice of action. 
 % Sweeps consist of a series of states that are selected on the basis of greatest expected reward.
 swlen=1;
 while (swlen<M.lsweepA) && (swcer(swlen)<M.actSweepCertThr)
   swlen=swlen+1;
   for iA=1:M.nA                        % Build the sweep for each action
    stX(iA)=localmax(M.Pm(:,stX(iA),:),M.Pr(2,ct,:)); % The next most promicing state
    pA(iA)  =pA(iA) + M.Pr(2,ct,stX(iA)); % Accumuluate reward evidence 
  end
  swcer(swlen)=acertainty(pA); 
 end
 
end

a=xmax(pA,M.beta);                      % The action with greatest chance for reward (noisy selection)

% OUTPUT
A.a=a;                                  % Action index (discrete)
A.swlen=swlen;                          % Sweep length
A.swcer=swcer;                          % Certainty of action selection

end

function c=acertainty(pA)               % Return the certainty of the most probable action given the available evidence
  pAs=sort(pA,'descend'); c=log(pAs(1)/pAs(2))/log(2); % Certainty (in bits) of the 1st relative to the 2nd most probable action.
end 
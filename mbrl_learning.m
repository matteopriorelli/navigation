function M=mbrl_learning(M,ST)
 i=M.i;                                 % Tick
 go=ST.goal.s;                          % Goal-index
 x0=M.x;                                % Input before applying the action
 z0=M.z;                                % State before applying the action
 a=M.A.a;                               % Selected action
 x1 =ST.inp;                            % Input after applying the action
 if ~M.Exp(x1),                         % Unexperienced input ?
   M=mbrl_extendmodel(M,x1);            % -> Extend the model wit CRP prior
 end
 PC0=M.Pc(x0,:);                        % Categorization distribution for input x0
 PC1=M.Pc(x1,:);                        % Categorization distribution for the new input x1
 [~,z1]=max(PC1);                       % the new state is the most probable one

 r=ST.r;                                % Are we at the goal-position ?
 if r            
   r=rand<ST.rewprob(ST.goal.room);     % If so, give reward with certain probability
 end
 R=[1-r;r];                             % Encode the local-reward as a distribution
 R=R*ST.rewscale;                       % Room-specific reward (it is the same in Phase1 and it is asymmetric in Phase2; see the paper for description) 
 R=R.*M.Nr(:,go,z1);                    % Turn the observed reward to Dirichlet counters

%% Learn the transition MODEL
M.Nm(z1,z0,a) = M.Nm(z1,z0,a) + 1;      % Update the Dirichlet distribution with the new transition evidence (arrive to s1, startig from s and applying a)
M.Pm(:,z0,a)   = M.Nm(:,z0,a) /sum(M.Nm(:,z0,a)); % The posterior of the model transition distribution (just normalize its Dirichlet prior)

%% LEARN the clustering 
PC0=PC0.*reshape(M.Pm(z1,:,a),1,M.nCAT);% for all CAT together     Using the actual transition
normPC=single(PC0/sum(PC0));            % normalize  to probabilities
M.Pc(x0 ,:) = normPC;                   % update the posterior    

%% Learn the REWARD function p(r|s2,c)
[NswpR,swl_lrn]=mbrl_rewardsweep(M,go,x1); % Make a reward-learning sweep 
tdmom=min(1,M.tdmom0/log10(i+1));       % momentum term
M.Nr(:,go,z1) = M.Nr(:,go,z1) + tdmom * (R+NswpR-M.Nr(:,go,z1)); % TD-like learning over the Dirichlet of the reward model
M.Pr(:,go,z1) = M.Nr(:,go,z1)/sum(M.Nr(:,go,z1)); % normalize to calculate the posterior of the reward model

%% STORE trial information
M.npath=ST.npath;                       % How many paths thus far
M.itrial=ST.npath;                      % Just alias
M.ss(i,:)     = single(M.xstate);       % Complete info about the stimulus and correct action
M.state(i)    = int8(ST.state);         % Model state after executing this step
M.action(i)   = uint8(a);               % Selected action 
M.rseq(i)     = uint8(r);               % Obtained reward 
M.lsweep(i)   = uint8(M.A.swlen);       % length of action-sweeps
M.cert(i)     = M.A.swcer(M.A.swlen);   % Certainty at the point of decision
M.lsweep_lrn(i) = uint8(swl_lrn);       % length of action-sweeps
if ST.state                             % If the search has finished
  M.path.success(ST.npath)=(ST.state>0);% Success in this path
  M.path.len(ST.npath)=ST.lpath;        % Path length
  M.path.goal(ST.npath,:)=[ST.goal.s ST.goal.room ST.goal.x ST.goal.y];   % Index,Room,X,Y of goal
  M.path.start(ST.npath,:)=[ST.start.x ST.start.y ST.start.d];            % X,Y,Dir at start
end

end 
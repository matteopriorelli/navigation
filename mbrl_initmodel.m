function M=mbrl_initmodel(M,x)
M.ntrials=M.task.ntrials;               % Learning trials to be done
M.nticks=M.task.nticks;                 % Expected time ticks
M.npaths=M.task.npaths;                 % Expected paths

%% Params
M.alpha = M.task.params(1);             % Dirichlet alpha param
M.beta = M.task.params(2);              % softmax choice inverse temperature
M.actpolicy=M.task.params(3);              
M.lsweepA=M.task.params(4);             % 5-6 Length of forward sweep for action selection
M.actSweepCertThr=M.task.params(5);     % Best 0.15. Acceptable 0.20-0.30;  log-probability difference to stop a sweep. (btw 1st and 2nd most probable action)
M.rewpolicy=M.task.params(6);
M.lsweepR=M.task.params(7); 
M.td_gam=0.90;                          % discount factor
M.td_gamj=exp(log(M.td_gam)*(1:12));    % j^1 j^2 .. j^k (the discount at each lookup-distance, to reduce calculations)
M.td_sweep=M.lsweepR;                   % max length of reward sweep
M.tdmom0=1.5;                           % momentum coef for the momentum curve

%% Storage for learning hystory
ntm=M.nticks;                           % How many learning trials to be done
M.ss     = zeros(ntm,7,'single');       % Full trial Info
M.state  = zeros(ntm,1,'int8');         % State at the end of the trial
M.rseq   = zeros(ntm,1,'uint8');        % reward
M.action = zeros(ntm,1, 'uint8');       % chosen action
M.Ncat   = zeros(ntm,1,'single');       % Approximate number of categories formed 
M.lsweep = zeros(ntm,1,'uint8');        % length of action-sweeps
M.cert   = zeros(ntm,1,'single');       % certainty of sweep
M.lsweep_lrn = zeros(ntm,1,'uint8');    % length of action-sweeps

ntr=M.ntrials;                          % How many expected paths
M.path.success=zeros(ntr,1, 'uint8');   % Success of each expected search path
M.path.len    =zeros(ntr ,1, 'uint8');  % Length of each search path
M.path.goal   =zeros(ntr ,4, 'single'); % Index,Room,X,Y of goal
M.path.start  =zeros(ntr ,3, 'single'); % X,Y,Dir of start

%% Problem-size
M.nA=M.task.act.n;                      % number of actions
M.nC=M.task.nStim(1);                   % Number of goals
M.nS=M.task.nStim(2);                   % Max number of dirichlett-states 
M.Exp=[]; M.nExp=0;                     % Indicator of experienced to-be-categorized states &  number of different experienced contexts at a goven moment
M.Pc=[];  M.nCAT=0;                     % P(TS|Ci) & number of categories learned 
M.Pm=[]; M.Nm=[];                       % P(s'|s,a) Probabily of next state given state and action & Conjugate prior
M.Pr=[]; M.Nr=[];                       % P(r|c,s) Probabily of reward given s' and goal & Conjugate prior
M.Exp=zeros(M.nS,1);                    % Bitmap of experienced input-states
M.Exp(x)=1;                            % Indicate that this state is experienced
M.nExp    =1;                           % The number of experienced states
M.nCAT    =1;                           % The number of dirichlett-categories learned
M.Pc=zeros(M.nS,M.nCAT,'single');       % P(TS|Si)
M.Pc(x)=1;                             % Init P(TS|C) with P(single task set | single conext thus far)
M.Pm=ones(M.nCAT,M.nCAT,M.nA,'single')/1;% P(s'|s,a) Probabily of next state given state and action
M.Nm=ones(M.nCAT,M.nCAT,M.nA,'single'); % Conjugate prior (dirichlett)
M.Pr=ones(2,M.nC,M.nCAT,'single')/2;    % P(r|C,TS) Reward-binomial
M.Nr=ones(2,M.nC,M.nCAT,'single');      % Conjugate priod (beta)

end
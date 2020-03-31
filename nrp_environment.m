function ST=nrp_environment(ST,task)   
 if isempty(ST), ST=init_episodes(task);  end   % Init of environment. To be set new episode!
 if ST.state, ST=new_episode(ST,task); end  % Generate new episode (trial)
 %ST=nrp_input(ST,task);                   % x=combined {Grid-code at the current position x head-direction}
end

function ST=init_episodes(task)
  ST.state=2;                % Indicator to generate new goal & initial position
  ST.npath=0;                % How many paths thus far;
  ST.lpath=0;                % How long is the current paths;
  ST.act=0;
  ST.goal.i=inf;             % Initial goal = intial state, to generate straight the real new goal and state 
  ST.pos.i=inf;              % Initial position 
  ST.pos.n=0;                % Initially no positions defined
  ST.phase.cont=1;           % 1st phase of contextualizing (all goals with the same probability)
  ST.phase.start=1;          % 1st phase of start points (close to center)
  ST.grid.map=zeros(task.grid.gmax*task.act.nturn,1,'single');
  ST.grid.list=[];
  ST.grid.n=0;
end

function ST=new_episode(ST,task)        % New EPISODE. Get a reward point and initial state

% Trial-based setting  (as in Pennartz)
  if ST.npath>task.phase.trial_start2, ST.phase.start=2; end % 1=start from center, 2=start from anywhere  
  %if ST.npath>=task.phase.trial_contextcue, ST.phase.cont=2; end 
  % 1=uniform reward, 2="contex cueing", i.e., assymetric reward
      
% GOAL (one out of pre-selected positions)
  ST.goal.i=ST.goal.i+1;                % Next goal (from the list of all goals)
  if ST.goal.i>=task.goals.n,           % If all goals are used, then reshufle
    ST.goal.I=randperm(task.goals.n);
    ST.goal.i=1;
  end
  ST.goal.s=ST.goal.I(ST.goal.i);       % index of goal 
  ST.goal.x=task.goals.x(ST.goal.s);    % x-position of goal
  ST.goal.y=task.goals.y(ST.goal.s);    % y-position of goal
  ST.goal.room=task.goals.room(ST.goal.s); % Associated room number
    
% START-POINT (tottaly random)
  start_ok=0;
  while not(start_ok)
    s_dista=rand*task.start.maxdist(ST.phase.start);      % position, distance from cetnre 
    s_theta=rand*2*pi;                  % position, theta (0-360 degree)
    [ST.start.x,ST.start.y]=pol2cart(s_theta,s_dista);  % position in cartesian coordinates
    ST.start.d=rand*2*pi;                                     % random head-direction (0-360 degree)
    %wx=max(1,min(task.wsize,round(ST.start.x+task.wsize/2)));
    %wy=max(1,min(task.wsize,round(ST.start.y+task.wsize/2)));
    wx=floor(ST.start.x+task.wsize/2)+1;
    wy=floor(ST.start.y+task.wsize/2)+1;
    start_ok=task.world(wy,wx);         % if positive, then it is in the arena. MK the binarized world representation used as a flag
  end
  
  ST.pos.x=ST.start.x;
  ST.pos.y=ST.start.y;
  ST.pos.d=ST.start.d;

% Service vars
  ST.act=0;                             % Initially, no predicted action
  ST.npath=ST.npath+1;                  % add a new path
  ST.lpath=0;                           % empthy path
  ST.rewscale=task.rewscale(ST.phase.cont); 
  ST.rewprob =task.rewprob(ST.phase.cont,:); 
  ST.state=0;
  %sprintf('episode: %d', ST.npath);
end


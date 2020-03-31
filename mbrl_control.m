function M=mbrl_control(M,ST)
 go=ST.goal.s;                          % Goal-index
 M.x =ST.inp;                           % Current input at the current position
 M.xstate=[ST.goal.s M.x ST.pos.x ST.pos.y ST.pos.d ST.npath ST.lpath];  % Store agent state(goal,stim,pos-x,pos-y,pos-dir,npath,lenpath) 

 M.i=M.i+1;                             % Time tick
 i=M.i;                                 % shortcut for the time tick
 if i==1, M=mbrl_initmodel(M,M.x); end    	% First-time model initialization
 if ~M.Exp(M.x)
   M=mbrl_extendmodel(M,M.x); 
 end  % Extend the model with unexperienced stimuli
 PC=M.Pc(M.x,:);                        % probability of each category given the input x
 [~,st]=max(PC);                        % the state is the most probable one
 M.A=mbrl_actionselection(M,go,st);         % Pick-up the expectedly most valuable action
 M.z=st;
end

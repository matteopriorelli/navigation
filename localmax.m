function st=localmax(Pm,Pr)             % Select the action that locally brings to max reward at this step of the sweep. Input is Pm(st1:,state,iA:) and Pr(2,st1:,target)
 [~,S]=max(Pm,[],1);                    % The most probable set of States (search on the 1st dimension) following  each possible action (the action is the 3rd dimension in Pm and the new state is the 1st dimension)
 [~,a]=max(Pr(S));                      % The action with max local reward (at each selected state)
 st=S(a);                               % "Apply" the action to go to the next state of the sweep (the most probable state for this action)
end
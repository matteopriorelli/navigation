function ST=nrp_action(ST,M,pos)
task=M.task;
%pos=ST.pos;                                     % start from the current position
%a=M.A.a;                                        % Action index

% Effects of 3 possible actions: move forward, move and turn left, move and turn right
%s_scale=[1  1   1 ];
%s_dir  =[0  1  -1 ];

%step=task.act.step*s_scale(a)*(1+randn*.1);     % Size of step in the new direction
%turn=s_dir(a)*task.act.turn+randn*0.1;          % Change of direction

%pos.d=pos.d+turn;
%if pos.d<0, pos.d=pos.d+2*pi; end
%if pos.d>=2*pi, pos.d=pos.d-2*pi; end
 
%[pos.dx,pos.dy]=pol2cart(pos.d,step);
%pos.x=pos.x+pos.dx;
%pos.y=pos.y+pos.dy;

% should stay inside world (pos.x/pos.y are 0-centered)
%pos.x=max(-task.wsize/2,min(task.wsize/2,pos.x));
%pos.y=max(-task.wsize/2,min(task.wsize/2,pos.y));

% Should stay inside arena
%yw=max(1,min(task.wsize,round(pos.y+task.wsize/2)));
%xw=max(1,min(task.wsize,round(pos.x+task.wsize/2)));

%if not(task.world(yw,xw)), pos=ST.pos; end      % Restore position if outside of environment

%% OUTPUT

%ST.pos=pos;                                     % Update the position
ST.pos.x=pos.x;
ST.pos.y=pos.y;
ST.pos.d=pos.d;
ST.r=((pos.x-ST.goal.x)^2+(pos.y-ST.goal.y)^2)^.5<1; % Are we at goal position ?
ST.lpath=ST.lpath+1;                            % Update path (episode) length

if ST.r                                         % Is the goal reached ?
  ST.state=1;                                   % Yes; ask for new learing path
elseif ST.lpath>task.path_max_length
  ST.state=-1;                                  % No, but too long trial, so ask for a new path.
end

ST=nrp_input(ST,task);                        % The grid-input at the new position 

return
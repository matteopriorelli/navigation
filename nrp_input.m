function ST=nrp_input(ST,task)
% Return the grid-cells code multiplied by head direction, and eventually updatethe dictionary

pos=ST.pos;

%% 1. Get position, grid reading, head direction, and multply them
gx=min(task.wsize,max(1,round(pos.x+task.wsize/2))); % Shift to positive coordinates and round to integer
gy=min(task.wsize,max(1,round(pos.y+task.wsize/2)));
dir=round(pos.d/(2*pi)*task.act.nturn); if dir==0, dir=task.act.nturn; end  % Map all directions on a discrete scale

g=task.grid.GRID(gy,gx);            % Enumerated grid-code at the current position 
g=(g-1)*task.act.nturn+dir;         % Add info about the orientation MK: Check this, note from the meeting

%% 2. APPLY DICTIONARY
if ST.grid.map(g)==0,               % Dictionary of grid inputs. Used to deacrease the table since to all inputs will be seen.
  ST.grid.n=ST.grid.n+1;            % Number of used grid levels
  ST.grid.list(ST.grid.n)=g;        % List of used grid levels
  ST.grid.map(g)=ST.grid.n;         % Map of used levels
end

ST.inp=ST.grid.map(g);              % Read the dictionary for this combined (multiplied) code

end
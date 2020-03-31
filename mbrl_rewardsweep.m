function [PrN,swl]=mbrl_rewardsweep(m,g,st)  % predict the next actions & states that bring to reward
 % g: target state, st: point of departure for the sweep
 PrN=zeros(2,1);                        % Accumualtor for the predicted reward, 
 if m.rewpolicy==1, 
     lsweepR=1; 
 else
     lsweepR=m.lsweepR; 
 end
 for swl=1:lsweepR
   st=localmax(m.Pm(:,st,:),m.Pr(2,g,:)); % Next state based on selecting the action with greatest chance for reward 
   PrN=PrN+m.Nr(:,g,st)*m.td_gamj(swl); %gam^j
 end
 PrN=PrN/swl;
end
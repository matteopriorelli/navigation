function [M,ST] = nrp_run

 rng('shuffle'); 
 params=[20 80 3 8 0.15 2 9];       % MBRL params
 ST = [];                           % Empty environment
 M=[];                              % Empty model
 M.task=nrp_init(params);           % Init the environment
 M.itrial=0;                        % Reset episode index
 M.i=0;                             % Reset time tick

 %[M,ST] = nrp_loop(M,ST);           % Training loop
 
 %ltrend(M);                         % Plot learning trends
  
end
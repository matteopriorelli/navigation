% Add a context experienced for the 1st time (to a TavolaCinese in a ChineseRestorant)
function M=mbrl_extendmodel(M,x)
% 1) Record state M.x in a list of experienced context 
M.nExp=M.nExp+1;                        % Increase number of experienced states
M.Exp(x)=M.nExp;                      % Add this state to the list of experienced states

% 2) Add a new task set that could potentially get this context 
M.Pc(x,M.nCAT+1)=0;                    % add a new column to P(TS|S)
% The probabilut of assigning the new context to a new TaskSet depends on parameter alpha
M.Pc(x,M.nCAT+1)=M.alpha/(M.alpha+M.nExp); % Set the prob of the new task-set 
% The probability of selecting "old" TSs depens their popularity accross all other contexts
M.Pc(x,1:M.nCAT)=sum(M.Pc(:,1:M.nCAT))/(M.alpha+M.nExp); % Rescale to account for the new entry

% 3) Extend the multinomial transition model P(s'|s,a) with a new TS
M.Nm(M.nCAT+1,:,:)=ones(1,M.nCAT  ,M.nA,'single'); 
M.Nm(:,M.nCAT+1,:)=ones(M.nCAT+1,1,M.nA,'single');
M.Pm = M.Nm ./ repmat(sum(M.Nm),[size(M.Nm,1) 1 1]); % Turn into conditional probabilities

% 4) Extend the binomial model of reward P(r|goal,state) with a new category(model state)
M.Nr(:,:,M.nCAT+1)=ones(2,M.nC,1,'single');
M.Pr(:,:,M.nCAT+1)=ones(2,M.nC,1,'single')/2;

% Finally, extend the number of learned categories (states)
M.nCAT=M.nCAT+1;         
end

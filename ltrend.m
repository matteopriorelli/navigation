% Show behavioral trens
function ltrend(M)

 episode=2700;

 figure;clf reset;hold on;  
 %nTr=M.task.ntrials;                                       % Number of trials (all learners are aligned by trials
 nTr=episode;
 nIpl=31;                                                        % Number of plot datapoints
 
 Ipl=(1:nIpl)*(nTr/nIpl);                                        % Plot time (in trials)
  
 nTm=M.i;                                               % Number of time ticks
 %nTr=M.ntrials;                                         % Actual number of trials to consider
 nTr=episode;
 AC=resampleivo(single(M.path.success(1:nTr)),1:nTr,nTr/nIpl)*100; 
 PL=resampleivo(single(M.path.len(1:nTr)),1:nTr,nTr/nIpl);
 SL=resampleivo(single(M.lsweep(1:nTm)),1:nTm,nTm/nIpl,nIpl);
 DC=resampleivo(single(M.cert(1:nTm)),1:nTm,nTm/nIpl,nIpl);   % Certainty at the point of decision
 
 nplt=4;
 subplot(1,nplt,1); hold on; plot(Ipl,AC,'LineWidth',3); 
 subplot(1,nplt,2); hold on; plot(Ipl,PL,'LineWidth',3); 
 subplot(1,nplt,3); hold on; plot(Ipl,SL,'LineWidth',3);
 subplot(1,nplt,4); hold on; plot(Ipl,DC,'LineWidth',3);

 %l_cc=M.task.phase.trial_contextcue;
 l_cc=episode;
 
subplot(1,nplt,1); hold on;
  line([1;1]*l_cc,[0;100],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'YLim',[0 100],'LineWidth',2); 
  xlabel('Trial');   ylabel('Percentage success');  title('Accuracy');
  
subplot(1,nplt,2); hold on;
  line([1;1]*l_cc,[10;40],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'LineWidth',2,'YLim',[10 40]); 
  xlabel('Trial');   ylabel('Path length'); title('Path length');

subplot(1,nplt,3); hold on;
  line([1;1]*l_cc,[0;7],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'LineWidth',2,'YLim',[0 7]); 
  xlabel('Trial');   ylabel('Control-Sweep Length'); title('Sweep Depth');

subplot(1,nplt,4); hold on;
  line([1;1]*l_cc,[0;1],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'LineWidth',2,'YLim',[0 1]);
  xlabel('Trial');   ylabel('Certainty');
  title('Decision certainty');
  
end

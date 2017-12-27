function trialcoeffs=fittrial(trial);

n=size(trial.speedpower,2);

trialcoeffs=zeros(n,3);
for i=1:n
% trialcoeffs(:,i)=polyfit(log(trial.speedpower(:,1,i))...
%    ,log(trial.speedpower(:,2,i)),1);                                                  % linear fit in log-log of speed power ballast

trialcoeffs(:,i)=polyfit(log(trial.speedpower(:,2,i))...
   ,log(trial.speedpower(:,1,i)),1);

% trialcoeffs(i,:)=polyfit((trial.speedpower(:,1,i) )...
%     ,(trial.speedpower(:,2,i)),2);                                                  % linear fit in log-log of speed power ballast

end

% plotting:
for i=1:n
v(:,i)=linspace(min(trial.speedpower(:,1,i))-2,max(trial.speedpower(:,1,i)),100);                               % x-values for plotting condition 1
p(:,i)=exp(trialcoeffs(2,i)).*v(:,i).^trialcoeffs(1,i); 
% p(:,i)=polyval(trialcoeffs(i,:),v(:,i));
end

% figure(1);                                                                    % plot speed power for trial points and fit                  
% hold on;
% caxis([7,14.5]);
% d=[7,14];
% for i=1:n
% % trial points:
% plot((trial.speedpower(:,1,i)),(trial.speedpower(:,2,i)),'.','MarkerSize',8);%'color',getcolorfromcaxis(d(i),colormap,caxis))
% % fit:
% plot((v(:,i)),(p(:,i)),'-'); %,'color',getcolorfromcaxis(d(i),colormap,caxis))
% end

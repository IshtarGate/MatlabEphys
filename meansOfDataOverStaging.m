x=NaN;
openvar('x')
%%
% 
% clf
% hold on
% for i=min(x(:,1)):max(x(:,1))
%     if x(i,2)==1
%        plot(x(i,1),x(i,4),'ro');
%      elseif x(i,2)==6
%        plot(x(i,1),x(i,4),'bo');
%     end
% end
% hold off
%%
counter=1
clear dateMean
clc
for i=min(x(:,1)):max(x(:,1))
    tempInd=find(x(:,1)==i);
    tempInd2=tempInd(find(x(tempInd,2)==6));
    if isempty(tempInd2)==0
    dateMean(counter,1)=i;
    dateMean(counter,2)=mean(x(tempInd,3));
    dateMean(counter,3)=std(x(tempInd,3));
    counter=counter+1;
    end
end
openvar('dateMean')
disp('done')
% create the empty variables
clear all
close all
clc
means=NaN;
stdevs=NaN;
meansAndDevs=NaN;
openvar('means');
openvar('stdevs');

%%
meansAndDevs={NaN(size(means,1),size(means,2))};
for j=1:size(means,1);
    for i=1:size(means,2);
        meansAndDevs{j,i}=[num2str(means(j,i)) ' ± ' num2str(stdevs(j,i))];
    end
end
openvar('meansAndDevs');
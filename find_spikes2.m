% This function will find spikes
%%
function [spikes, spkfreq] = find_spikes(time_column, data)
%%
 minamp=20;
 x = time_column;
 y = data(:,1);
 [ymax,imax,ymin,imin] = extrema(y);
 plot(x,y,x(imax),ymax,'g.',x(imin),ymin,'r.');

% return maximum spikes above a certain amplitude
a = [ymax imax];
b = find(a(:,1)>minamp);
c = a(b,2);


output{i} =[data(c,1) time_column(c)];

spikes=output
%%
for i=1:j
a = sortrows(output{i},2);
spkfreq(i,1) = (a(end,2)-a(1,2))/size(output{i},1);
end
%%
clear dongs diff1 diff2
clf
for i=1:20000-20
    diff1(i,1)=(dong(i+2)-dong(i))/(i+2-i);
end
for i=1:20000-40
    diff2(i,1)=(diff1(i+2)-diff(i))/(i+2-i);
end
hold on
plot(diff1,'g.')
plot(diff2,'y.')

%%

dongs=zeros(40000,2);
for i=20000:39000
    dongs(i,1)=i;
    difference=dong(20000:20100,1)-dong(i:i+100,1);
    dongs(i,2)=mean(difference);
end
plot(dong)
hold on
plot (dongs(:,1),dongs(:,2),'r.')
%%
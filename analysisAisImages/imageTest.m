clf
plot(x(:,1),x(:,2),'ro');
hold on
z=fit(x(:,1),x(:,2), 'smoothingspline');%'cubicinterp'
plot(x(:,1),x(:,3),'ro');
z1=fit(x(:,1),x(:,3), 'smoothingspline');%'smoothingspline'

bRange=-80:1:-10;
plot(bRange,z(bRange),'b')
plot(bRange,z1(bRange),'b')

y=([bRange' z(bRange) z1(bRange)]);

%%
clf
plot(0:.005:10,z(0:.005:10),'ro')
%%
clf
a=zeros(100);

a(20:30,20:30)=1;
imshow(a)
b=imresize(imrotate(a,30),[100 100]);
c=[a b];
imshow(c)
sum(sum(a))
sum(sum(b))
%%
a=ones(100);
a(20:30,20:30)=0;
%c=imresize(a,2);

imshow(a)
b=imrotate(c,30,'crop');
%b=imresize(b,0.5);
imshow(b)
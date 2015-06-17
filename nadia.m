a=control;
%%
b=NaN(1000,1000);
%%
% for row_you_start_with=1:size(a,1)-1
% x_col=1+2*(row_you_start_with-1);
% y_col=2*row_you_start_with;
%     for inc=row_you_start_with+1:size(a,1)
%         b(inc,x_col:y_col)=a(row_you_start_with,:)-a(inc,:);
%     end
% end
%%
for row_you_start_with=1:size(a,1)-1
    for inc=row_you_start_with+1:size(a,1)
        c=a(row_you_start_with,:)-a(inc,:);
        b(inc,row_you_start_with)=sqrt(c(1)^2+c(2)^2);
    end
end

d=reshape(b,1000000,1);
%%
clf
nanmean(nanmean(b));
myaxis=[0 .2 0 150];
binranges=0:.002:1;
[bincounts]= histc(b,binranges);
bar(binranges,bincounts,'histc')
axis manual
axis(myaxis)
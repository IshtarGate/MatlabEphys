[file,path]=uigetfile;
pathfile=strcat(path,file);
d=abfload(pathfile);
%%
clear d2
trace_start=350
trace_length=1200;
for i=1:size(d,3)
d2(trace_start:trace_length,i)=d(trace_start:trace_length,1,i);
end
%%
clear d3
reduction_factor=20;
reduction_factor2=2;
for i=1:size(d2,1)/reduction_factor
    for j=1:size(d2,2)/reduction_factor2
        d3(i,j)=d2(reduction_factor*i,reduction_factor2*j);
    end
end
surf(d3)
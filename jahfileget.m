%%
function [SelectedData,pathfilename]=jahfileget();
clear d data def dialoganswer dlg_title filename header i m n num_lines path path_filename pathfilename prompt si
dialoganswer=1;
pathfilename={};
while dialoganswer==1
[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
path={path};
if iscell(filename)==0
    filename={filename};
else
end

filename=filename';
for i=1:size(filename,1)
path_filename(i,1) = strcat(path,filename(i));
end
if isempty(pathfilename)==1
    pathfilename=path_filename;
else
    n=size(pathfilename,1);
    for i=1:size(path_filename,1)
        m=i+n;
        pathfilename(m,1)=path_filename(i);
    end
end
prompt = {'1=yes 0=no'};
dlg_title = 'Would you like to get more files?';
num_lines = 1;
def = {'1'};
dialoganswer = inputdlg(prompt,dlg_title,num_lines,def);
dialoganswer=cell2mat(dialoganswer);
dialoganswer=str2num(dialoganswer);
if dialoganswer==1
else
    break
end
end
%%
for n=1:size(pathfilename,1)
    clear d d2;
    [d,~,header]=abfload(char(pathfilename(n)));
    for i = 1:size(d,3);%condense the file
    d2(:,i)= d(:,1,i);
    end
    data{n}=d2;
end
SelectedData=data';
end
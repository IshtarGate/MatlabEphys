%% find file using a copied filename from excel
%% prompt for filename minus .abf
prompt = {'input filename without .abf'};
dlg_title = 'Find File';
num_lines = 1;
def = {''};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
fullpath= inputdlg(prompt,dlg_title,num_lines,def,options);
fullpath=char(fullpath)
%% add .abf
fullpath=which(strcat(fullpath, '.abf'))
%% load data to d
d=abfload(fullpath);
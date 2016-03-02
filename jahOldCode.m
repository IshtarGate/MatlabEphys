% jahOldCode stores old code
% this is not a functional m file



%% Pick protocol to use (by hand way)
% commandwindow;
% % protocolBeingAnalyzed=5;
% protocolBeingAnalyzed=input('1=CCIV, 2=evoked, 3=Ihy 4=Thy 5=CCIVhippo 6=EPR hippo:  ');
% commandwindow;
%% uigetfile
% [filenames,path] = uigetfile('*.abf','.abf File','MultiSelect','on');

%% opening files
% some old shit code
% tempfilename=char(filenames{fileNumber});
% filename=tempfilename;
% if iscell(filenames)==1
% path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
% filename=filenames{fileNumber};
% else
% path_filename = strcat(dirOfMatFiles,filenames);
% filename=filenames;
% end
%
% load(path_filename);
% filename=tempfilename;
%function [abfFilesInDirCell]=jahGetABFfileNames()
% getABFfileNames can be used like this
%   [abfFilesInDirCell]=getABFfileNames();
% and will open itself as the cell abfFilesInDirCell
%  
% use something like this to open a file obtained by getABFfileNames
% 
% abfload(['C:\Users\James\Documents\Dropbox\Lab\mfiles\vitro\nd project\wt m 20150622\' a(1).name]);
% 
%%
jahCleanUp
cd(uigetdir())
ABFfilesInDirStruct=dir('*.abf');

abfFilesInDirCell=cell(size(ABFfilesInDirStruct,1),1);
for i=1:size(ABFfilesInDirStruct,1)
abfFilesInDirCell{i}=ABFfilesInDirStruct(i).name;
end
openvar('abfFilesInDirCell');

disp('Copy the filenames from abfFilesInDirCell')

% openvar('ABFfilesInDirStruct');

%%
% data=abfload(['C:\Users\James\Documents\Dropbox\Lab\mfiles\vitro\nd project\wt m 20150622\' ABFfilesInDir(1).name]);
    
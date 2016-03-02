%% add this code to the start of every new matlab script
% this code clears the matlab path and then adds all of the folders from
% the shared matlab dropbox folder as well as sets figures to be docked and
% cleans up all variables and figures
restoredefaultpath
addpath(genpath('C:\Users\James\Documents\Dropbox\Lab\mfiles'));
jahCleanUp();

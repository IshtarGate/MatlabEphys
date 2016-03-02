%% jahAbfToPrismScript
% script using jahAbfToPrism2() to convert abf files to prism graphs
%% set defaults and clear old variables
restoredefaultpath
try
addpath(genpath('C:\Users\James\Documents\Dropbox\Lab\mfiles'));
catch
end
jahCleanUp(); % clean all variables, figures, and command window


% ***** User Inputs *****
    maxNumberOfPointsToPlot=600; % how many points in the final time/voltage plot per sweep
    useTheseSweeps=[8 10 11 12];%[14 25 36 47]; %[ 9 17 25 33]; % use sweep numbers [10 20 30 40] or 'All';
    xAxisStart=1;%50 % x axis start time (in milliseconds)
    xAxisStop=500; %500 % x axis stop time (in milliseconds)

    % Will you stack several current steps in a figure? Do you want the
    % AP's shortened so they stack nicely?
    makeTruncatedApGraph='True'; % 'True' or 'False'
    voltagesGreaterThanThisWillBeTruncated=-25; %the last sweep will not be truncated




%load input for jahAbfToPrism2
    jahAbfToPrism2Inputs=struct('one',maxNumberOfPointsToPlot,...
        'two',useTheseSweeps,'three',xAxisStart,'four',xAxisStop,...
        'five', makeTruncatedApGraph, 'six', voltagesGreaterThanThisWillBeTruncated);

% call function jahAbfToPrism2
    [plotOutput,plotOutput3]=jahAbfToPrism(jahAbfToPrism2Inputs);
%% Create a file that holds analyzed data or appends additional analyzed data to that file
filename_of_analyzed_data = 'Analyzed_Data.mat';
if exist('Analyzed_Data')==0    
Analyzed_Data=[Spike_Sheet(2,:) num2cell(Input_Resistance2(3,:)) num2cell(Spike_Freq2)];
elseif iscell(Analyzed_Data)==1
Analyzed_Data(size(Analyzed_Data,1)+1,:)...
    =[Spike_Sheet(2,:) num2cell(Input_Resistance2(3,:)) num2cell(Spike_Freq2)];
end
save(filename_of_analyzed_data, 'Analyzed_Data');
%%
clear
[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
path_filename = strcat(path,filename);

%%
[d,si,header]=abfload(path_filename);
data = zeros(size(d,1),size(d,3));
for i = 1:size(d,3);%condense the file
    data(:,i) = d(:,1,i);
end;
%% Find max and mins

size_data = size(data);
min_data = zeros(1,size_data(1,2));
for i = 1:size_data(1,2)
    min_data(1,i) = min (data(:,i));
end

max_data = zeros(1,size_data(1,2));
for i = 1:size_data(1,2)
    max_data(1,i) = max(data(:,i));
end

%% find average
avg_data = zeros(1,size_data(1,2));
for i = 1:size_data(1,2) ;
    avg_data(1,i) = mean(data(1:500,i));
end
%% differences
diff_variable_state=avg_data-min_data;

diff_ap = max_data-avg_data;

%%

hypc = {'RMP' 'Variable State' 'AP' 'Diff Variable State' 'Diff AP'};
hypc_sheet = zeros(size_data(1,2),5);
hypc_sheet(:,1) = avg_data';
hypc_sheet(:,2) = min_data';
hypc_sheet(:,3) = max_data';
hypc_sheet(:,4) = diff_variable_state';
hypc_sheet(:,5) = diff_ap';
hypc_sheet = hypc_sheet';

%% find the index for 120mv

index_table = abs(120+min_data);
[row,col] = find(index_table==min(index_table(:)));
rel_adp_at_120 = hypc_sheet(end,col);


    
    
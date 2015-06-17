%% this is the multi load program
%protocol_list=cell(43,1);
%save protocol_list.mat protocol_list;

%% clean house
set(0,'DefaultFigureWindowStyle','docked');%make figures dock
set(0,'DefaultFigureCreateFcn','zoom on');%make it so you can zoom by default
clear all
clc
close all

%% find all *.abf files in dir
load protocol_list.mat ;
dir_i_want=uigetdir();
my_dir=dir( strcat(dir_i_want, '\*.abf'));
my_list=cell(size(my_dir,1),2);
for inc1=1:size(my_dir,1)
    my_list{inc1}=[my_dir(inc1).name];
end
%% reduce to just names
for inc1=1:size(my_dir,1)
    disp(my_list(inc1,1));
    my_list(inc1,2)=protocol_list(inc1);
end
%%
for inc1=1:size(my_list,1)
    my_list{inc1,3}=dir_i_want;
end
%% run protocol
output_dump=cell(size(my_list,1),105);
for inc=1:size(my_list)
    disp(inc);
    temp_var=my_list(inc,2);
    %if cell2mat(my_list(inc,2)) == 2
        path=strcat(dir_i_want, '\');
        filename=char(my_list(inc,1));
        %% This loads the file
        cd(path)
        path_filename = strcat(path,filename);
        [data,si,header]=abfload(path_filename, 'sweeps','a');
        d = zeros(size(data,1),size(data,3));
        for loop_number = 1:size(data,3);%condense the file
            d(:,loop_number) = data(:,1,loop_number);
        end;
        number_of_milliseconds_in_sweep=size(d,1)*(si/1000);...
            %calculate the number of milliseconds
        time = [0:number_of_milliseconds_in_sweep/(size(data,1)-1):...
            number_of_milliseconds_in_sweep]';%create time column
        
        %%
        %Plot sweeps via 10x5 graphs
        min_of_data=min(min(d));
        max_of_data=max(max(d));
        for loop_number = 1:size(d,2);%plot the sweeps
            if loop_number> 30 
                break
            end
            subplot(6,5,loop_number);
            plot(time,d(:,loop_number));
            axis manual;
            axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
        end
        h = figure(1);
        set(h,'name',filename,'numbertitle','off');
        pause(.5)
        %% i hy stats
        %allocate empty matricies
        output=cell(1,105);
        rmp=NaN(1,20);
        variable_state=NaN(1,20);
        adp=NaN(1,20);
        delta_variable_state=NaN(1,20);
        delta_adp=NaN(1,20);
        
        mat_size=size(d,2);
        if mat_size>20
            mat_size=20;
        end
        
        for sweep=1:mat_size
            rmp(sweep)=mean(d(1:2000,sweep));
        end
        for sweep=1:mat_size
            variable_state(sweep)=min(d(:,sweep));
        end
        for sweep=1:mat_size
            adp(sweep)=max(d(:,sweep));
        end
        for sweep=1:mat_size
            delta_variable_state(sweep)=abs(variable_state(sweep)-rmp(sweep));
        end
        for sweep=1:mat_size
            delta_adp(sweep)=abs(adp(sweep)-rmp(sweep));
        end
        
        blank=NaN(1,1);
        output=[filename num2cell(rmp) num2cell(blank) num2cell(variable_state)...
            num2cell(blank) num2cell(adp) num2cell(blank)...
            num2cell(delta_variable_state) num2cell(blank) num2cell(delta_adp)];
        clear blank;
        clf
        output_dump(inc,:)=output;%% important variable
    %end
end
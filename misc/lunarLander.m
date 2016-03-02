% Lunar Lander Game
% Will Schleter June, 2010
% uses 

%% init
clear all; close all; clc;
g = 32.2 ./ 6; % lunar gravity, ft/s/s
h = randi([2000 4000],1); % starting height
v = randi([-80,-60],1); % starting velocity
weight = 2000; % lbs
mass = weight./g; % lander mass, tons divided by gravity
playing_flag = 1;
t = 0; % elapsed time in seconds
dt = 1; % time interval in seconds
vmax = 5; % max successful landing speed - ft/s

%% instructions
fprintf('You are in a %.0f lb lunar lander\n',weight);
fprintf('Try to land with a speed of less than %.0f ft/s\n',vmax);

%% loop until done
while playing_flag==1
    %% show current position and velocity
    fprintf('Time: %3.0f sec, Altitude: %6.1f ft, Velocity: %5.1f ft/s\n',t,h,v);
    %% get user input
    input_flag = 1;
    while input_flag==1
        thrust = input('Enter vertical thrust (k-lbs/s) <0>: ');
        if isempty(thrust)
            thrust = 0;
        end
        if abs(thrust)<=10
            input_flag=0;
        else
            fprintf('Invalid input, thrust must be between -10 and 10\n');
        end
    end
    
    %% calculate new values
    a = -g + thrust*1000./mass;

    % time to hit the ground from this position
    % if it is less than dt, use it
    thit = roots([a./2 v h]);
    if length(thit)>=1 && isreal(thit(1)) && thit(1)>0 && thit(1)<dt
        dt=thit(1);
    end
    if length(thit)>=2 && isreal(thit(2)) && thit(2)>0 && thit(2)<dt
        dt=thit(2);
    end
    
    h = h + v.*dt + a./2.*dt.*dt;
    v = v + a.*dt;
    t = t + dt;
        
    
    %% check to see if we are down
    if abs(h)<=0.1
        playing_flag = 0;
        if abs(v)<vmax
            msg = 'Success!';
        else
            msg = 'Crash!';
        end
        fprintf('%s You landed with a velocity of %.1f ft/s\n',msg,v);
    end
end
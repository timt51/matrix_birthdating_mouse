%Explore data for variations in mouse center of mass velocity (cm/s) during
%and not during stimulation

%import data
load('time_velocity_data.mat');

%Remove first 5 empty cells, trial 1 ("active" mouse) ends on 7500
velocity = velocity(6:7500);
time_intervals = time_intervals(6:7500);

%change time intervals to start times, could use optimization?
start_times = zeros(length(time_intervals),1);
for i = 1:length(time_intervals)
    start_times(i) = second(datetime(time_intervals{i}(1:11), 'InputFormat' ,'h:mm:ss.SSS')) + minute(datetime(time_intervals{i}(1:11), 'InputFormat' ,'h:mm:ss.SSS'))*60;
end

%Average over each minute
n = 25; % average every n values (25Hz)
velocity = reshape(velocity,[],1);
velocity = arrayfun(@(i) mean(velocity(i:i+n-1)),1:n:length(velocity)-n+1)'; % the averaged vector
start_times = start_times(1:n:length(start_times)); start_times = start_times(2:end);

%Clean velocity data by thresholding
%Mean: 100.7284, Standard Deviation: 96.9569
threshold = 100;
v = velocity(velocity < threshold);

%Corresponding time intervals
t = start_times(velocity < threshold);

%First 15 seconds not stimulated, then 3 seconds stimulated, 12 seconds not
%stimulated, repeat -> find mean and std of velocity when stimulated and
%not stimulated
stimulated_vs = [];
not_stimulated_vs = [];
for i = 1:length(t)
    st = t(i);
    if (st > 15 && mod(st,15) >= 0 && mod(st,15) <= 3)
        stimulated_vs = cat(1,stimulated_vs,v(i)); %needs optimization
    else
        not_stimulated_vs = cat(1,not_stimulated_vs,v(i)); %needs optimization
    end
end


%Make normalized bar charts of data
[counts_s, centers_s] = hist(stimulated_vs, linspace(5, 95, 10));
[counts_ns, centers_ns] = hist(not_stimulated_vs, linspace(5, 95, 10));
figure(1); bar(centers_s, counts_s/sum(counts_s)); xlim([0 100]); ylim([0 .35]); title('Stimulated Velocities (Threshold 100cm/s)'); xlabel('Velocity(cm/s)'); ylabel('Normalized Frequency (% of total)');
figure(2); bar(centers_ns, counts_ns/sum(counts_ns)); xlim([0 100]); ylim([0 .35]); title('Not Stimulated Veclocities (Threshold 100cm/s)'); xlabel('Velocity(cm/s)'); ylabel('Normalized Frequency (% of total)');

%display means and stds
ys = [mean(stimulated_vs), mean(not_stimulated_vs)];
errs = [std(stimulated_vs), std(not_stimulated_vs)];
figure(3); barwitherr(errs, ys); title('Comparison of Means for Stimulated and Not Stimulated'); xlabel('1 - Stimulated, 2-Not Stimulated'); ylabel('Mean Velocity (cm/s)');
import Makie
import VideoIO

## Load video
# video_file =  VideoReader('64caf10.avi');
# video_file =  VideoReader('56ub310.avi');
video_file = VideoIO.open("649j210.avi")
video_info = video_file.video_info

vid_width = video_file.Width;
vid_height = video_file.Height;
vid_frames_cont = video_file.Duration*video_file.FrameRate;
## Create set of evenly distributed indicies
number_of_points = 15;

horizontal_indicies = 1:floor(vid_width/number_of_points):vid_width;
vertical_indicies = 1:floor(vid_height/number_of_points):vid_height;

## Create set of randomly distributed indicies
# number_of_points = 20;
#
# horizontal_indicies = rand(1,number_of_points);
# horizontal_indicies = uint64(horizontal_indicies*vid_width);
#
# vertical_indicies = rand(1,number_of_points);
# vertical_indicies = uint64(vertical_indicies*vid_height);

## Extract  pixel changes
extracted_pixels = zeros(size(vertical_indicies,2),...
                         size(horizontal_indicies,2),...
                         vid_frames_cont);

frame_number = 1;
while hasFrame(video_file)
    vid_frame = readFrame(video_file);
    gray_frame = rgb2gray(vid_frame);

    extracted_pixels(:,:,frame_number) = gray_frame(vertical_indicies,...
                                                    horizontal_indicies);
    frame_number = frame_number + 1;
end

## Reshape the extracted pixels to the vector form
rows = size(extracted_pixels,1);
number_of_signals = rows^2;
vector_pixels = zeros(number_of_signals, length(extracted_pixels));

index = 1;
for row=1:rows
    for column=1:rows
        vector_pixels(index,:) = extracted_pixels(row, column,:);
        index = index+1;
    end
end

# Consider the signals as neuron spike train in the total time duration T
# At this point, the set of vectors may be considered as raw EEG recordings
# The following procedure must be applied now:
# 1. Spike sorting
# 2. Spike average for time bin
# 3. generation of the signal with same average spiking
# 4. Crosscorelation of average spike bin
# 5. The pairwise correlations Cij (blue
## 1-3: Generate spike train from signal and
# simulate the spike train with the same average fring rate
threshold = 25;
spike_interval = 25; #this works as a refraction period
signal_duration = vid_frames_cont;
spike_train = zeros(number_of_signals, signal_duration);
simulated_spike_train = zeros(number_of_signals, signal_duration);
average_firing_rate = zeros(number_of_signals, 1);

for k = 1:number_of_signals
#     [spike_count ,spike_index] = spike_times(vector_pixels(k,:),threshold);
    [spike_count, spike_index] = get_spikes(vector_pixels(k,:),threshold, spike_interval);

    spike_train(k,spike_index) = 1;
    average_firing_rate(k) = spike_count/signal_duration;

    simulated_spike_train(k,:) = rand(1, signal_duration) < average_firing_rate(k);
end

##
C_ij = zeros(number_of_signals);
T = size(vector_pixels,2);
interval_length = 20;
subs = zeros(T,1);

# used_signal = vector_pixels;
used_signal = spike_train;

for row=1:number_of_signals
    for column=1:number_of_signals
        signal_ij = used_signal(row,:);
        signal_ji = used_signal(column,:);

        # Create mean over intervals
        # This is taking the mean firing rate of the neuron spike train
        subs = zeros(T,1);
        for i=1:interval_length:T
            subs(i:end) = subs(i:end) + 1;
        end
        sumed_signal_1 = accumarray(subs, signal_ij,[],@sum);
        sumed_signal_2 = accumarray(subs, signal_ji,[],@sum);
        time_axis = (1:length(sumed_signal_1))*interval_length ;
# Plot
        # cross_corelation
        [ccg_ij, lags] = xcorr(signal_ij, signal_ji); # , 'normalized'
#       [ccg_ij, lags] = xcorr(sumed_signal_1, sumed_signal_2); # , 'normalized'
#         [ccg_ji, lags] = xcorr(sumed_signal_2, sumed_signal_1);
        ccg_ij = ccg_ij / T;
#         ccg_ji = ccg_ji / T;

        [ccg_rr, lags2] = xcorr(simulated_spike_train(row,:), ...
                                simulated_spike_train(column,:));
        r_i_r_j = mean(ccg_rr);
        # correlation matrix
        [max_val_ij, middle_ij] = max(ccg_ij);
#         [max_val_ji, middle_ji] = max(ccg_ji);
        middle_ij = floor(length(ccg_ij)/2);
#         middle_ji = middle_ij;
        tau_max = 25; # this is given in frames

        A = sum(ccg_ij(middle_ij-tau_max:middle_ij+tau_max));
#         B = sum(ccg_ji(middle_ji:middle_ji+tau_max ));
        C_ij(row, column) = max([A])/(tau_max*r_i_r_j);

# #  figure
# clf('reset')
# subplot(3, 1, 1)
# hold on
# plot(signal_ij)
# plot(signal_ji)
# hold off
# xlabel("Frame number")
# ylabel("Pixel value")
# legend("Signal 1", "Signal 2")
# title(sprintf("row: #d, column: #d",row, column))
#
# subplot(3, 1, 2)
# hold on
# plot(time_axis, sumed_signal_1, 'x-')
# plot(time_axis, sumed_signal_2, 'x-')
# hold off
# xlabel("Frame number")
#
# subplot(3, 1, 3)
# stem(lags, ccg_ij)
# hold on
# # plot(lags, ones(length(lags),1)*aver, lags, ones(length(lags),1)*C_ij(row, column))
# hold off
# xlabel("Frame bin shift")
# ylabel("Normalized coerrelation")
# legend("Crosscorelation", "r_i*r_j", "C_i_j")
    end
end

##
# clf('reset')
figure
imagesc(log10(C_ij))
colorbar
# subplot(3, 1, 1)
# hold on
# plot(signal_ij)
# plot(signal_ji)
# hold off
# xlabel("Frame number")
# ylabel("Pixel value")
# legend("Signal 1", "Signal 2")
#
# subplot(3, 1, 2)
# hold on
# plot(x, averaged_signal_1, 'x-')
# plot(x, averaged_signal_2, 'x-')
# hold off
# xlabel("Frame number")
# ylabel(sprintf("Pixel sum over #d frames",frames))
# legend("Averaged signal 1", "Averaged signal 2")
#
# subplot(3, 1, 3)
# stem(lags, ccg_ij)
# xlabel("Frame bin shift")
# ylabel("Normalized coerrelation")
# legend("Crosscorelation")

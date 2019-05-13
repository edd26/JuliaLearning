import Makie
 import VideoIO
 using MATLAB
 using StatsBase
 using Plots

@enum VIDEO candle=1 water=2 checkboard=3 coral_reef=4

choice = candle
 simulate_spikes = false

 if choice == candle
    video_streamer = VideoIO.open("64caf10.avi") # candle
 elseif choice == water
    video_streamer = VideoIO.open("56ub310.avi") # water
 elseif choice == checkboard
    video_streamer = VideoIO.open("649j210.avi") # checkboard
 elseif choice == coral_reef
    video_streamer = VideoIO.open("64ac220.avi") # coral reef
 end

 video_length = 0;
 video_array = Vector{Array{UInt8}}(undef,0);
 video_file = VideoIO.openvideo(video_streamer, target_format=VideoIO.AV_PIX_FMT_GRAY8)
 vid_width = video_file.width;
 vid_height = video_file.height;


# Read the video into the array

while !eof(video_file)
    push!(video_array,reinterpret(UInt8, read(video_file)))
    global video_length += 1
 end
 close(video_file)

# video_file.Duration*video_file.FrameRate;
## Create set of evenly distributed indicies
number_of_points = 20;
 horizontal_indicies = 1:Int64(floor(vid_width/number_of_points)):vid_width;
 columns = size(horizontal_indicies,1)
 vertical_indicies = 1:Int64(floor(vid_height/number_of_points)):vid_height;
 rows = size(vertical_indicies,1)

## Create set of randomly distributed indicies
# number_of_points = 20;
#
# horizontal_indicies = rand(1,number_of_points);
# horizontal_indicies = uint64(horizontal_indicies*vid_width);
#
# vertical_indicies = rand(1,number_of_points);
# vertical_indicies = uint64(vertical_indicies*vid_height);

## Extract  pixel changes
extracted_pixels = zeros(rows, columns, video_length);
 for frame_number in 1:video_length
    extracted_pixels[:,:,frame_number] = video_array[frame_number][vertical_indicies, horizontal_indicies]
 end

## Reshape the extracted pixels to the vector form
 number_of_signals = rows*columns
 vectorized_video = zeros(number_of_signals, video_length);

 index = 1;
 for row=1:rows
    for column=1:columns
        vectorized_video[index,:] = extracted_pixels[row, column,:];
        global index = index+1;
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
 signal_duration = video_length;
 spike_train = zeros(number_of_signals, video_length);
 simulated_spike_train = zeros(number_of_signals, video_length);
 average_firing_rate = zeros(number_of_signals, 1);

if simulate_spikes
   for k = 1:number_of_signals
   #     [spike_count ,spike_index] = spike_times(vectorized_video(k,:),threshold);
       mat"[spike_count, spike_index] = get_spikes($vectorized_video($k,:),$threshold, $spike_interval);"

       spike_train(k,spike_index) = 1;
       average_firing_rate(k) = spike_count/signal_duration;

       simulated_spike_train(k,:) = rand(1, signal_duration) < average_firing_rate(k);
   end
end
##
C_ij = zeros(number_of_signals,number_of_signals);
 log_C_i_j = zeros(number_of_signals,number_of_signals);
 T = video_length # size(vectorized_video,2);
 interval_length = 20;
 subs = zeros(T,1);
 tau_max = 25; # this is given in frames
 lags = -tau_max:1:tau_max


used_signal = vectorized_video;
# used_signal = spike_train;

for row=1:number_of_signals
    for column=1:number_of_signals
        signal_ij = used_signal[row,:];
        signal_ji = used_signal[column,:];

        # cross_corelation
        #  MATLAB is 10 times slower than Julia in computing crosscorrelation
        ccg_ij = crosscov(signal_ij, signal_ji, lags);
        ccg_ij = ccg_ij ./ T;


        A = sum(ccg_ij[tau_max+1:end]);
        B = sum(ccg_ij[1:tau_max+1]);
 r_i_r_j = 1;
        C_ij[row, column] = max(A, B)/(tau_max*r_i_r_j);
        log_C_i_j[row, column] = log10(abs(C_ij[row, column]));
    end
end

##
# clf('reset')
heatmap(C_ij,  color=:lightrainbow, title="Cij, $choice, number of points: $number_of_signals")

heatmap(log_C_i_j,  color=:lightrainbow, title="log10 Cij, $choice, number of points: $number_of_signals")

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

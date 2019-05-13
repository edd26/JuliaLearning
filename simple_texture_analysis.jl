using MATLAB
 using StatsBase
 using Plots
 include("VideoManage.jl")

@enum VIDEO candle=1 water=2 checkboard=3 coral_reef=4

choice = candle
 simulate_spikes = false

 if choice == candle
    video_name = "64caf10.avi" # candle
 elseif choice == water
    video_name = "56ub310.avi" # water
 elseif choice == checkboard
    video_name = "649j210.avi" # checkboard
 elseif choice == coral_reef
    video_name = "64ac220.avi" # coral reef
 end

# Read the video into the array
video_array = get_video_array_from_file(video_name)
video_dim_tuple = get_video_dimension(video_array)

# video_file.Duration*video_file.FrameRate;
## Create set of uniformly distributed indicies
points_per_dim = 10;

indicies_set = get_video_mask(points_per_dim, video_dim_tuple)
extracted_pixels = extract_pixels_from_video(video_array, indicies_set, video_dim_tuple)
vectorized_video = vectorize_video(extracted_pixels)

## Reshape the extracted pixels to the vector form

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


heatmap(C_ij,  color=:lightrainbow, title="Cij, $choice, number of points: $number_of_signals")

heatmap(log_C_i_j,  color=:lightrainbow, title="log10 Cij, $choice, number of points: $number_of_signals")

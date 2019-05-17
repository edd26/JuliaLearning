using MATLAB
 using StatsBase
 using Plots
 include("VideoManage.jl")
 include("GeometricMatrix.jl")
 include("clique_top_Julia/clique_top.jl")

@enum VIDEO candle=1 water=2 checkboard=3 coral_reef=4

choice = candle
 simulate_spikes = false
 points_per_dim = 10;
 tau_max = 25;
 video_path = "video_database/"

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
 video_array = get_video_array_from_file(video_path*video_name)
 video_dimensions = get_video_dimension(video_array)
 indicies_set = get_video_mask(points_per_dim, video_dimensions)
 extracted_pixels = extract_pixels_from_video(video_array,
                                                 indicies_set, video_dimensions)
 vectorized_video = vectorize_video(extracted_pixels)

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


C_ij = get_pairwise_correlation_matrix(vectorized_video, tau_max)

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

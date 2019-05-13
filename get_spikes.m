function [spike_count ,spike_index] = get_spikes(trace,threshold, spike_interval)
% Create spike train for given data set
%   Detailed explanation goes here
    spike_index = zeros(size(trace));
    trace = trace >= threshold;

    k = 1;
    while(k<length(trace))
        if(trace(k)==1)
            spike_index(k) = k;
            k=k+spike_interval;
        else
            k=k+1;
        end
    end
    
    spike_index(spike_index==0) = [];
    spike_count = sum(trace(spike_index));
end


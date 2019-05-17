import Makie
 import VideoIO
 using StatsBase


 """
     get_video_array_from_file(video_name)

 Returns array to which video frames are copied. Frames are in grayscale.

 Function opens stream, then loads the file and gets all the frames from a
 video.
 """
function get_video_array_from_file(video_name)
   video_streamer = VideoIO.open(video_name) # candle
   video_array = Vector{Array{UInt8}}(undef,0);
   video_file = VideoIO.openvideo(video_streamer, target_format=VideoIO.AV_PIX_FMT_GRAY8)

   while !eof(video_file)
      push!(video_array,reinterpret(UInt8, read(video_file)))
   end
   close(video_file)

   return video_array
end

"""
    get_video_dimension(video_array)

Returns the tuple which contains width, height and the number of the frames of
array in whcih video was loaded.
"""
function get_video_dimension(video_array)
   v_hei = size(video_array[1],1)
   v_wid = size(video_array[1],2)
   v_len = size(video_array,1)

   video_dim_tuple = (video_height=v_hei, video_width=v_wid, video_length=v_len)

   return video_dim_tuple
end

"""
    get_video_mask(points_per_dim, video_dim_tuple; distribution="uniform", sorted=true)

Returns matrix of size @points_per_dim x 2 in which indicies of video frame are
stored. The indicies are chosen based one the @distribution argument. One option
is uniform distribution, the second is random distribution.

Uniform distribution: distance between the points in given dimension is the even,
but vertical distance may be different from horizontal distance between points.
This depends on the size of a frame in a image.

Random distribution: the distance between the points is not constant, because
the points are chosen randomly in the ranges 1:horizontal size of frame,
1:vertical size of frame. The returned values may be sorted in ascending order,
if @sorted=true.
"""
function get_video_mask(points_per_dim, video_dimensions; distribution="uniform", sorted=true)
    video_height = video_dimensions[1]
    video_width = video_dimensions[2]


    if distribution == "uniform"
        columns = points_per_dim
        rows = points_per_dim

        # +1 is used so that the number of points returned is as requested
        row_step = Int64(floor(video_height/rows))
        column_step = Int64(floor(video_width/columns))

        (video_height/row_step != points_per_dim) ? row_step+=1 : row_step
        (video_width/column_step != points_per_dim) ? column_step+=1 : video_width

        vertical_indicies = collect(1:row_step:video_height)
        horizontal_indicies = collect(1:column_step:video_width)

        vertical_indicies = reshape(vertical_indicies, (1,points_per_dim))
        horizontal_indicies = reshape(horizontal_indicies, (1,points_per_dim))

        indicies_set = [vertical_indicies; horizontal_indicies]

    elseif distribution == "random"
        vertical_indicies = rand(1:video_height,1, points_per_dim)
        horizontal_indicies = rand(1:video_width,1, points_per_dim)

        if sorted
            vertical_indicies = sort(vertical_indicies[1,:])
            horizontal_indicies = sort(horizontal_indicies[1,:])

            vertical_indicies = reshape(vertical_indicies, (1,points_per_dim))
            horizontal_indicies = reshape(horizontal_indicies, (1,points_per_dim))
        end
        indicies_set = [vertical_indicies; horizontal_indicies]
    end

   return indicies_set
end

"""
    extract_pixels_from_video(video_array, indicies_set, video_dim_tuple)

Takes every frame from @video_array and extracts pixels which indicies are in
@indicies_set, thus creating video with only chosen indicies.
"""
function extract_pixels_from_video(video_array, indicies_set, video_dim_tuple)
   rows = size(indicies_set,2)
   columns = size(indicies_set,2)
   video_length = video_dim_tuple[3]

   extracted_pixels = zeros(rows, columns, video_length)
   for frame_number in 1:video_length
      extracted_pixels[:,:,frame_number] =
                video_array[frame_number][indicies_set[1,:],indicies_set[2,:]]
   end

   return extracted_pixels
end


"""
    vectorize_video(video)

Rearrenges the video so that set of n frames (2D matrix varying in
time) the set of vectors is returned, in which each row is a pixel, and each
column is the value of the pixel in n-th frame.
"""
function vectorize_video(video)
    video_length = size(video, 3)
    rows = size(video,1)
    columns = size(video,2)

    number_of_vectors = rows*columns

    vectorized_video = zeros(number_of_vectors, video_length)

    index = 1;
    for row=1:rows
        for column=1:columns
            vectorized_video[index,:] = video[row, column,:];
            index = index+1;
        end
    end

    return vectorized_video
end

"""
    get_pairwise_correlation_matrix(vectorized_video, tau_max=25)

Computes pairwise correlation of the input signals accordingly to the formula
presented in paper "Clique topology reveals intrinsic geometric structure
in neural correlations" by Chad Giusti et al.

The Computations are done only for upper half of the matrix, the lower half is
a copy of upper half. Computation-wise the difference is at level of 1e-16, but
this causes that inverse is not the same as non-inverse matrix.

"""
function get_pairwise_correlation_matrix(vectorized_video, tau_max=25)
    number_of_signals = size(vectorized_video,1)
    T = size(vectorized_video,2)

    C_ij = zeros(number_of_signals,number_of_signals);
    # log_C_ij = zeros(number_of_signals,number_of_signals);

     # this is given in frames
    lags = -tau_max:1:tau_max


    for row=1:number_of_signals
        for column=row:number_of_signals
            signal_ij = vectorized_video[row,:];
            signal_ji = vectorized_video[column,:];

            # cross_corelation
            ccg_ij = crosscov(signal_ij, signal_ji, lags);
            ccg_ij = ccg_ij ./ T;

            A = sum(ccg_ij[tau_max+1:end]);
            B = sum(ccg_ij[1:tau_max+1]);
            r_i_r_j = 1;
            C_ij[row, column] = max(A, B)/(tau_max*r_i_r_j);
            C_ij[column, row] = C_ij[row, column]
            # log_C_i_j[row, column] = log10(abs(C_ij[row, column]));
        end
    end

    return C_ij
end


"""
    get_average_from_tiles(extracted_pixels_matrix, N)

Fnction takes a 3D array in which video is stored and splits every frame into
non overlaping tiles of size NxN. If size of @extracted_pixels_matrix is not square of N, then only N^2 x N^2 matrix will be used for averaging.
"""
function get_average_from_tiles(extracted_pixels_matrix, N)
    # N = size(extracted_pixels,1)
    num_frames = size(extracted_pixels_matrix,3)
    mask_matrix = ones(N, N)
    result_matrix = zeros(N, N, num_frames)
    col_index = 1
    row_index = 1

    for frame = 1:num_frames
        for col = 1:N:N^2
            for row = 1:N:N^2
                result_matrix[mod(col,N), mod(row,N), frame] =
                        dot(extracted_pixels_matrix[col:(col+N-1), row:(row+N-1), frame], mask_matrix) ./N^2
                row_index += 1
            end
            col_index += 1
        end
    end
    return result_matrix
end

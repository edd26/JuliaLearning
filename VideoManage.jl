import Makie
 import VideoIO


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
   video_height = size(video_array[1],1)
   video_width = size(video_array[1],2)
   video_length = size(video_array,1)

   video_dim_tuple = (video_height, video_width, video_length)

   return video_dim_tuple
end


function get_video_mask(points_per_dim, video_dim_tuple; distribution="uniform", sorted=true)
    video_height = video_dim_tuple[1]
    video_width = video_dim_tuple[2]


    if distribution == "uniform"
        columns = points_per_dim
        rows = points_per_dim

        # +1 is used so that the number of points returned is as requested
        row_step = Int64(floor(video_height/rows))+1
        column_step = Int64(floor(video_width/columns))+1

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

function vectorize_video(video)
    video_length = size(extracted_pixels, 3)
    rows = size(extracted_pixels,1)
    columns = size(extracted_pixels,2)

    number_of_vectors = rows*columns

    vectorized_video = zeros(number_of_vectors, video_length)

    index = 1;
    for row=1:rows
        for column=1:columns
            vectorized_video[index,:] = extracted_pixels[row, column,:];
            index = index+1;
        end
    end
    
    return vectorized_video
end

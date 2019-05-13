import Makie
 import VideoIO

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

function get_video_dimension(video_array)
   video_length = size(video_array,1);
   video_width = size(video_array[1],1);
   video_height = size(video_array[1],2);

   video_dim_tuple = (video_width, video_height, video_length)

   return video_dim_tuple
end

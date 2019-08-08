using MultivariateStats, RDatasets, Plots
using VideoIO
using ImageTransformations

#=

 =#

# Generate data set from the video
# Convert to grayscale
# Resize the images
# Vectorize images
include("../Settings.jl")
include("../VideoProcessing.jl")

video_name = "checkerboard.avi"
   video_path = test_params["video_path"]

   video_streamer = VideoIO.open(video_path*video_name) # candle
   video_array = Vector{Array{UInt8}}(undef,0);

   video_file = VideoIO.openvideo(video_streamer, target_format=VideoIO.AV_PIX_FMT_GRAY8)

   number_of_frames = 170
   size_x = 128
   size_y = 128
   size_squarred = size_x*size_y

   vectorized_video = zeros(size_squarred, number_of_frames)

   while !eof(video_file)
      for frame = 1:number_of_frames
         img = floor.(imresize(reinterpret(UInt8, read(video_file)), size_x, size_y))
         push!(video_array, img)

         img = reshape(img, 1, size_squarred) # this is done column after column
         vectorized_video[:,frame] = img
      end
      break
   end
   close(video_file)

# Apply PCA
train_size = 150
   train_array = vectorized_video[:,1:train_size]
   test_array =  vectorized_video[:,train_size:end]

   M = fit(PCA, train_array; maxoutdim=10)
   # apply PCA model to testing set
   Yte = transform(M, test_array)

   # reconstruct testing observations (approximately)
   Xr = reconstruct(M, Yte)
# Plot the results

frame_number = 20

reconstructed_img = reshape(Xr[:,frame_number], size_x, size_y)
plotimg(reconstructed_img)
plotimg(video_array[frame_number])



#=
 test of the fft f the vectorized image
=#
using FFTW


# Using FFT method creates artifacts, which may be hatmful for the segmentation
frame_number = 1
fft_result = fft(vectorized_video[:,frame_number])

fft_mag = abs.(fft_result)
half_size = Int(floor(size(fft_mag)[1]/2))

plot(fft_mag[1:half_size], yaxis=:log)



fft_result = fft(Xr[:,frame_number])

fft_mag = abs.(fft_result)
half_size = Int(floor(size(fft_mag)[1]/2))

plot(fft_mag[1:half_size], yaxis=:log)

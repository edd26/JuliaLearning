# using Images
using Plots
 using ImageFiltering
 using ImageView
 include("VideoProcessing.jl")
 include("Settings.jl")

 ENV["JULIA_DEBUG"] = "all"


choice =  VIDEO.reef
 video_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/videos/"
 video_generated = "/home/ed19aaf/Programming/Julia/JuliaLearning/video_generated/"
 @info "Video path is set to:" video_path


if choice == VIDEO.diag_1
    video_name = "diag_strip_30sec_1.mov"
  elseif choice == VIDEO.diag_2
    video_name = "diag_strip_30sec_2.mov"
  elseif choice == VIDEO.diag_g1
    video_name = "diag_strip_30sec_gray_1.mov"
  elseif choice == VIDEO.diag_g2
    video_name = "diag_strip_30sec_gray_2.mov"
  elseif choice == VIDEO.diag_gb
    video_name = "diag_strip_30sec_gray_both.mov"
  elseif choice == VIDEO.diag_dbl
    video_name = "diag_strip_30sec_single_dbl_gaps.mov"
  elseif choice == VIDEO.horiz
    video_name = "horiz_strip_30sec.mov"
  elseif choice == VIDEO.water
    video_name = "56ub310.avi"
  elseif choice == VIDEO.reef
    video_name = "64ac220.avi"
  elseif choice == VIDEO.candle
    video_name = "64caf10.avi"
  elseif choice == VIDEO.checkboard
    video_name = "649j210.avi"
  end


choice = video_name
@info "Selected video: " choice
@debug "Path and choice is:" video_path*choice

video_array = get_video_array_from_file(video_path*choice)
@info "Array extracted."

video_dimensions = get_video_dimension(video_array)


full_img = video_array[1]
img = full_img[1:150, 1:150]
 imshow(img)


img_filt = imfilter(img, Kernel.gaussian(5))
 imshow(img_filt)


img_dog = imfilter(img, Kernel.DoG(5))
 imshow(img_dog)


imgl = imfilter(img, Kernel.Laplacian());
 imshow(imgl)


img_LoG = imfilter(img, Kernel.LoG(7));
 imshow(img_LoG)


kernel = centered(rand(3,3))
 img_ker = imfilter(img,kernel)
 imshow(img_ker)
# Gradient
img_gradient = imgradients(img, KernelFactors.ando3, "replicate")
im1 = imshow(img_gradient[1])
im2 = imshow(img_gradient[2])


abs_gradient = map(abs, img_gradient[1]) + map(abs, img_gradient[2])
  imshow(abs_gradient)
  max_val, max_coord = findmax(abs_gradient)
  mean_val = mean(abs_gradient)

  a = (abs_gradient .> (max_val-mean_val)/3)
  imshow(a)
  mean(a)

  abs_gradient_filt = imfilter(abs_gradient, Kernel.gaussian(1))
  imshow(abs_gradient_filt)

# gaussian pyramid
n_scales = 2
downsample = 2
sigma = 0.5
pyramid = gaussian_pyramid(img, n_scales, downsample, sigma)

imshow(pyramid[5])

# Left for future processing
# indicies_set = get_video_mask(points_per_dim, video_dimensions,  distribution=ind_distrib, patch_params)
#
# extracted_pixels_matrix = extract_pixels_from_video(video_array, indicies_set, video_dimensions)
# @info "Pixels extracted."
#
# vectorized_video = vectorize_video(extracted_pixels_matrix)

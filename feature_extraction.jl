# using Images
using Plots
 using ImageFiltering
 using ImageView
 include("VideoProcessing.jl")
 include("Settings.jl")

ENV["JULIA_DEBUG"] = "all"
save_files = false


choice =  VIDEO.reef
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
img = full_img#[1:150, 1:150]
 plotimg(img)
 save(results_path*"$(split(choice, ".")[1]).png", colorview(Gray, normalize_to_01(img)))


img_filt = imfilter(img, Kernel.gaussian(5))
 plotimg(img_filt)


img_dog = imfilter(img, Kernel.DoG(5))
 plotimg(img_dog)


imgl = imfilter(img, Kernel.Laplacian());
 plotimg(imgl)


img_LoG = imfilter(img, Kernel.LoG(7));
 plotimg(img_LoG)


kernel = centered(rand(3,3))
 img_ker = imfilter(img,kernel)
 plotimg(img_ker)


# Gradient
img_gradient = imgradients(full_img, KernelFactors.ando3, "replicate")
plotimg(img_gradient[1])
plotimg(img_gradient[2])

if save_files
  save(results_path*"vertical_gradient_chceck.png", colorview(Gray, normalize_to_01(img_gradient[1])))
  save(results_path*"horizontal_gradient_chceck.png", colorview(Gray, normalize_to_01(img_gradient[2])))
end

abs_gradient = map(abs, img_gradient[1]) + map(abs, img_gradient[2])
  plotimg(abs_gradient)
  max_val, max_coord = findmax(abs_gradient)
  mean_val = mean(abs_gradient)
  if save_files
    save(results_path*"abs_sum_gradient_chceck.png", colorview(Gray, normalize_to_01(abs_gradient)))
  end

abs_gradient_filt = imfilter(abs_gradient, Kernel.gaussian(1))


# gaussian pyramid
n_scales = 2
downsample = 2
sigma = 0.5
pyramid = gaussian_pyramid(img, n_scales, downsample, sigma)

plotimg(pyramid[2])

"""
Script for texture generation. The goal is to use the method described by
    J. Portilla and E. Simoncelli and reconstruct the textures of the images.
"""
include("VideoProcessing.jl")
include("Settings.jl")
using Statistics
using Plots
 using ImageFiltering
 using ImageView



# Load the image to replicate:
choice = test_params["videos_names"][3]
video_array = get_video_array_from_file(test_params["video_path"]*choice)
video_dimensions = get_video_dimension(video_array)
full_img = video_array[1]



# Extract the features:
img_mean = mean(full_img)
img_var = var(full_img) # ratio of the standard deviation to the mean
img_kurt = skewness(full_img)
img_skew = kurtosis(full_img)



# gaussian pyramid
n_scales = 4
downsample = 2
sigma = 1
pyramid = gaussian_pyramid(full_img, n_scales, downsample, sigma)

plotimg(pyramid[1])
# plotimg(pyramid[2])
plotimg(pyramid[3])
# plotimg(pyramid[4])
plotimg(pyramid[5])

sum(pyramid[1] .* full_img)/(256*video_dimensions.video_height * video_dimensions.video_width)

image_cross_corr(full_img, pyramid[1])

function image_cross_corr(image, subimage, shift = 2)
    total_corr = 0

    # image = full_img
    # sub_img = pyramid[1]
    img_h, img_w = size(image)
    simg_h, simg_w = size(sub_img)

    subimg_x_ind = 1:simg_h
    subimg_y_ind = 1:simg_w
    last_x_shift = img_h - simg_h + shift
    last_y_shift = img_w - simg_w + shift

    for x_shift = 1:shift:last_x_shift
        for y_shift = 1:shift:last_y_shift
            local_sum = sum(image[subimg_x_ind.+x_shift, subimg_y_ind.+y_shift] .* sub_img)
            total_corr += local_sum/(256*simg_h*simg_w)
        end
    end
    return total_corr
end

# Reconstruct the image

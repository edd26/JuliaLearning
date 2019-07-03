using Images, ImageView
using ImageSegmentation
using Random
using FFTW, Plots

using Clustering

img = Gray.(load("img/checkerboard.png"))
# imshow(img)

seeds = [(CartesianIndex(126,81),1), (CartesianIndex(93,255),2), (CartesianIndex(213,97),3)]
    segments = seeded_region_growing(img, seeds)
    segment_mean(segments)
    imshow(map(i->segment_mean(segments,i), labels_map(segments)));

segments = felzenszwalb(img, 100)
    imshow(map(i->segment_mean(segments,i), labels_map(segments)))

segments = felzenszwalb(img, 15, 20)
    function get_random_color(seed)
        Random.seed!(seed)
        rand(RGB{N0f8})
    end
    imshow(map(i->get_random_color(i), labels_map(segments)))


segments = unseeded_region_growing(img, 0.08)
    imshow(map(i->segment_mean(segments,i), labels_map(segments)));
segments = meanshift(img, 20, 15/255)
 # parameters are smoothing radii: spatial=16, intensity-wise=8/255
    imshow(map(i->segment_mean(segments,i), labels_map(segments)));

imgg = imfilter(img, Kernel.gaussian(3));
segments = unseeded_region_growing(imgg, 0.08)
    imshow(map(i->segment_mean(segments,i), labels_map(segments)));

segments = meanshift(imgg, 20, 15/255)
 # parameters are smoothing radii: spatial=16, intensity-wise=8/255
    imshow(map(i->segment_mean(segments,i), labels_map(segments)))


# Using FFT method creates artifacts, which may be hatmful for the segmentation
F = fftshift(fft(Float64.(img)))
heatmap(log.(abs.(F.*F)).+1)
mask = zeros(size(img))
middle_ver = Int(floor(size(img)[1]/2))
middle_hor = Int(floor(size(img)[2]/2))
mask_size = 50
mask[middle_ver-mask_size:middle_ver+mask_size,
                    middle_hor-mask_size:middle_hor+mask_size] .= 1
imshow(mask)
# mask = Bool.(mask)
F = F .* mask
heatmap(log.(abs.(F.*F)).+1)
inversed_image = ifft(F)
imshow(abs.(inversed_image))

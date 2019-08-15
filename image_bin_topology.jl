using ImageFeatures, TestImages, Images, ImageDraw, CoordinateTransformations
using Plots

include("VideoProcessing.jl")

img = load("img/RT6_6.png")
# img = testimage("lighthouse")
img1 = Gray.(img)

imgg = imfilter(img, Kernel.gaussian(3));

thr_step = 50
thresholds = 1:thr_step:255
thresholds /= 255

function bin_image(img1, thresholds, thr_step; gauss_blurr=true)
    if gauss_blurr
        img2 = imfilter(img, Kernel.gaussian(3));
    else
        img2 = copy(img1)
    end


    for thr in thresholds
        indices = findall(x->x>=thr && x<thr+thr_step, img1)
        img2[indices] .= thr
    end

    return img2
end


img2 = bin_image(img1, thresholds, thr_step)
img2

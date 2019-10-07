using ImageFeatures
 using TestImages
 using Images
 # ImageDraw,
 # CoordinateTransformations
 using ImageSegmentation
 using Plots
 using Random

 include("VideoProcessing.jl")

plot_img = true

init_img = load("img/RT6_6.png")
# init_img = testimage("lighthouse")
img1 = Gray.(init_img)

thr_step = 50
thr_max = 255
thresholds = (1:thr_step:thr_max)/thr_max
thr = thresholds[5]

function bin_image(img, thresholds, thr_step; do_gauss_blurr=true, gauss_blurr=5)
    # img=img1
    if do_gauss_blurr
        img2 = imfilter(img, Kernel.gaussian(gauss_blurr));
    else
        img2 = copy(img)
    end

    for thr in thresholds
        indices = findall(x->x>=thr && x<(thr+thr_step), img2)
        img[indices] .= thr
    end

    return img
end


img2 = bin_image(img1, thresholds, thr_step, gauss_blurr=15)

#(this does the same things as binning after gaussian blurr)
segments = meanshift(img2, 16, 10/255)
#  Whta is shown here
segments1 = meanshift(img1, 16, 15/255)


# parameters are smoothing radii: spatial=16, intensity-wise=8/255
plot_img ? imshow(map(i->segment_mean(segments,i), labels_map(segments))) : (1)

function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

imshow(map(i->get_random_color(i), labels_map(segments)))

imshow(map(i->get_random_color(i), labels_map(segments1)))

# Now we should transform the segmented image into nodes and connect them if
 # they are neighbours
# How the segments are correlated with their statistical descriptors


# Get the center of the segments
seg_pix_count = segment_pixel_count(segments)
seg_map = labels_map(segments)
size_threshold = 50
regions_count = size(segment_labels(segments))[1]
seg_centers = zeros(Float64, 3, regions_count)
seg_data = Dict()
seg_mean = segment_mean(segments)


for segment in segment_labels(segments)
   if seg_pix_count[segment] > size_threshold
      index_set = findall(x->x==segment, seg_map)
      indicies = size(index_set)[1]
      center_x = 0
      center_y = 0
      for k = 1:indicies
         center_x += index_set[k][1]
         center_y += index_set[k][2]
      end
      center = Float64.(floor.([center_x;center_y]./indicies))
      seg_centers[1:2,segment] = center
      seg_centers[3,segment] = seg_mean[segment]

      seg_var = var(img[index_set])
      seg_std = std(img[index_set])
      seg_data[segment] = vcat(center, seg_mean[segment], seg_pix_count[segment], seg_var, seg_std)
   end
end

for center = 1:regions_count
   if seg_centers[1,center] > 0 && seg_centers[2,center] > 0
      seg_map[Int(seg_centers[1,center]),Int(seg_centers[2,center])] = 255
   end
end

# create array from dictionary
data_matrix = zeros(6, length(seg_data))

counter = 1
for element in seg_data
   data_matrix[:,counter] = element[2][:]
   global counter +=1
end
data_matrix = zeros(6, length(segments))

counter = 1
for element in seg_data
   data_matrix[:,counter] = element[2][:]
   global counter +=1
end

## Topology test

my_maxdim = 2

distance_matrix = pairwise(Euclidean(), data_matrix, dims=2)
distance_matrix ./= findmax(distance_matrix)[1]

using Images, ImageView
using ImageSegmentation
using Random
using FFTW, Plots

using Clustering
using Statistics


img = Gray.(load("img/checkerboard.png"))
imshow(img)

imgg = imfilter(img, Kernel.gaussian(1));
imshow(imgg)

# segments = unseeded_region_growing(imgg, 0.08)
#     imshow(map(i->segment_mean(segments,i), labels_map(segments)));


# Method below takes a lot of time time but returns multiple segments
segments = meanshift(imgg, 16, 10/255)
 # parameters are smoothing radii: spatial=16, intensity-wise=8/255
    imshow(map(i->segment_mean(segments,i), labels_map(segments)))
#

# Get the center of the segments
seg_pix_count = segment_pixel_count(segments)
seg_map = labels_map(segments)
size_threshold = 21
seg_centers = Dict()

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
      seg_centers[segment] = Int.(floor.([center_x/indicies, center_y/indicies]))
   end
end

heatmap(labels_map(segments))

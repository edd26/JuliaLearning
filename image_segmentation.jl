using Images, ImageView
   using ImageSegmentation
   using Random
   using Plots
   using Statistics
   using MATLAB
   using Distances

plot_img = false


img = Gray.(load("img/checkerboard.png"))
   plot_img ? imshow(img) : ()
imgg = imfilter(img, Kernel.gaussian(1));
   plot_img ? imshow(imgg) : ()

# Method below takes a lot of time time but returns multiple segments
segments = meanshift(imgg, 16, 10/255)
 # parameters are smoothing radii: spatial=16, intensity-wise=8/255
    plot_img ? imshow(map(i->segment_mean(segments,i), labels_map(segments))) : ()

include("VideoProcessing.jl")

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

## Topology test

my_maxdim = 2

distance_matrix = pairwise(Euclidean(), data_matrix, dims=2)
distance_matrix ./= findmax(distance_matrix)[1]


# clique-top computations
betti_num = 0
edgeDensities_r = 0;
persistenceIntervals = 0;
unboundedIntervals = 0;
mat"""addpath('clique-top')
      A = 0;
      B = 0;
      C = 0;
      D = 0;
      [A, B, C, D] = compute_clique_topology($distance_matrix(1:60, 1:60), 'Algorithm', 'split', 'MaxEdgeDensity', 0.6);
      $betti_num = A;
      $edgeDensities_r = B;
      $persistenceIntervals = C;
      $unboundedIntervals = D;"""

plot(edgeDensities_r', betti_num)



# Plotting
an_image = plotimg(labels_map(segments))

save("segmented_checkerboard.jpg", an_image)
plot(seg_centers[3,:])

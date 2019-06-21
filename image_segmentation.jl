using Images, ImageView
   using ImageSegmentation
   using Random
   using Plots
   using Statistics

   include("VideoProcessing.jl")



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
size_threshold = 50
regions_count = size(segment_labels(segments))[1]
seg_centers = zeros(Float64, 3, regions_count)
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
      seg_centers[1:2,segment] = Int.(floor.([center_x;center_y]./indicies))
      seg_centers[3,segment] = seg_mean[segment]
   end
end

for center = 1:regions_count
   if seg_centers[1,center] > 0 && seg_centers[2,center] > 0
      seg_map[Int(seg_centers[1,center]),Int(seg_centers[2,center])] = 255
   end
end

## Eirene Test
using Eirene

my_maxdim = 2

segments_eirene = eirene(seg_centers, model="pc", maxdim=my_maxdim)
segments_eirene = betticurve(geom_eirene, dim=1)
 segments_betti = zeros(size(segments_eirene)[1], 3+1)
 segments_betti[:,1] = segments_eirene[:,1]
 for k in 1:3
     segments_betti[:,k+1] = betticurve(geom_eirene, dim=k)[:,2]
 end
 matrix = segments_betti
 maxy = findmax(matrix[:,2])[2]
 plot(matrix[:,1], matrix[:,2], label="Random matrix, dim=1", ylims = (0,maxy))
 plot!(matrix[:,1], matrix[:,3], label="Random matrix, dim=2")
 plot!(matrix[:,1], matrix[:,4], label="Random matrix, dim=3")



##

# Plotting
plotimg(labels_map(segments))


plot(seg_centers[3,:])

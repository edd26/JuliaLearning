using Images, ImageView
using ImageSegmentation
using Random
using FFTW, Plots

using Clustering

img = Gray.(load("img/checkerboard.png"))
imshow(img)

imgg = imfilter(img, Kernel.gaussian(3));
segments = unseeded_region_growing(imgg, 0.08)
    imshow(map(i->segment_mean(segments,i), labels_map(segments)));

segments = unseeded_region_growing(img, 0.08)
    imshow(map(i->segment_mean(segments,i), labels_map(segments)));

# Method below takes a lot of time time
segments = meanshift(imgg, 16, 10/255)
 # parameters are smoothing radii: spatial=16, intensity-wise=8/255
    imshow(map(i->segment_mean(segments,i), labels_map(segments)))
#

# Get the center of the segments

findmin(labels_map(segments))





seg = felzenszwalb(img, 10, 100);
weight_fn(i,j) = euclidean(segment_pixel_count(seg,i), segment_pixel_count(seg,j));
G, vert_map = region_adjacency_graph(seg, weight_fn);

g = graphfamous("karate")
gplot(g)

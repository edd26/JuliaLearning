using ImageFeatures, TestImages, Images, ImageDraw, CoordinateTransformations
using Plots

include("VideoProcessing.jl")

img = load("img/RT6_6.png")
img = testimage("lighthouse")
img1 = Gray.(img)
rot = recenter(RotMatrix(5pi/6), [size(img1)...] .÷ 2)  # a rotation around the center
tform = rot ∘ Translation(-50, -40)
img2 = warp(img, rot, axes(img))
img2 = Gray.(img2)


#= ############################################################################
    BRISK algorithm example
=#
features_1 = Features(fastcorners(img1, 12, 0.35))
features_2 = Features(fastcorners(img2, 12, 0.35))

brisk_params = BRISK()

desc_1, ret_features_1 = create_descriptor(img1, features_1, brisk_params)
desc_2, ret_features_2 = create_descriptor(img2, features_2, brisk_params)

matches = match_keypoints(Keypoints(ret_features_1), Keypoints(ret_features_2), desc_1, desc_2,  0.1)

grid = hcat(img1, img2)
offset = CartesianIndex(0, size(img1, 2))
map(m -> draw!(grid, LineSegment(m[1], m[2] + offset)), matches)

grid


#= ############################################################################
    FREAK algorithm example
=#
keypoints_1 = Keypoints(fastcorners(img1, 12, 0.35))
keypoints_2 = Keypoints(fastcorners(img2, 12, 0.35))

freak_params = FREAK()

desc_1, ret_keypoints_1 = create_descriptor(img1, keypoints_1, freak_params)
desc_2, ret_keypoints_2 = create_descriptor(img2, keypoints_2, freak_params)

matches = match_keypoints(ret_keypoints_1, ret_keypoints_2, desc_1, desc_2, 0.1)

grid = hcat(img1, img2)
offset = CartesianIndex(0, size(img1, 2))
map(m -> draw!(grid, LineSegment(m[1], m[2] + offset)), matches)

grid

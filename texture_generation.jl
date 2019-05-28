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

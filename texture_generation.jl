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

using MATLAB
mat"cd('textureSynth')"
# s1 = MSession()

# Load the image to replicate:
k=11
 choice = test_params["videos_names"][k]
 video_array = get_video_array_from_file(test_params["video_path"]*choice)
 video_dimensions = get_video_dimension(video_array)
 full_img = video_array[1]

 im = convert.(Int64, full_img)
 # save("/home/ed19aaf/Dropbox/P_S_images/img$(k)_50.png", colorview(Gray, normalize_to_01(im)))
 @mput im

mat"
	close all

	% im0 is a double float matrix!
    im0 = pgmRead('text.pgm');
	% im0 = double(imread('test_img.png'));
	% im0 = double(im);


	Nsc = 4; % Number of scales
	Nor = 4; % Number of orientations
	Na = 9;  % Spatial neighborhood is Na x Na coefficients
		 % It must be an odd number!

	params = textureAnalysis(im0, Nsc, Nor, Na);

	Niter = 25;	% Number of iterations of synthesis loop
	Nsx = 256;	% Size of synthetic image is Nsy x Nsx
	Nsy = 256;	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

	res = textureSynthesis(params, [Nsy Nsx], Niter);

	close all
	figure(1)
	showIm(im0, 'auto', 1, 'Original texture');
	figure(2)
	showIm(res, 'auto', 1, 'Synthesized texture');

    %imwrite(res, 'img$(k)_50-256-256_synthesis.png')
    "
# mat"pwd()"

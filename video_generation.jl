using Images
using Makie
using VideoIO
using Logging

# Image processing packages
using ImageFeatures, TestImages, Images, ImageDraw, CoordinateTransformations
include("VideoManage.jl")


ENV["JULIA_DEBUG"] = "all"


VIDEO = (diag_1=1,
           diag_2=2,
           diag_g1=3,
           diag_g2=4,
           diag_gb=5,
           diag_dbl=6,
           horiz=7)

do_clique_top = false
do_eirene = true
choice = VIDEO.horiz
save_figures = true
plot_betti_figrues = true
plot_vectorized_video = false
tau_max = 5
points_per_dim = 9


video_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/videos/"
video_generated = "/home/ed19aaf/Programming/Julia/JuliaLearning/video_generated/"
@info "Video path is set to:" video_path


if choice == VIDEO.diag_1
  video_name = "diag_strip_30sec_1.mov"
elseif choice == VIDEO.diag_2
  video_name = "diag_strip_30sec_2.mov"
elseif choice == VIDEO.diag_g1
  video_name = "diag_strip_30sec_gray_1.mov"
elseif choice == VIDEO.diag_g2
  video_name = "diag_strip_30sec_gray_2.mov"
elseif choice == VIDEO.diag_gb
  video_name = "diag_strip_30sec_gray_both.mov"
elseif choice == VIDEO.diag_dbl
  video_name = "diag_strip_30sec_single_dbl_gaps.mov"
elseif choice == VIDEO.horiz
  video_name = "horiz_strip_30sec.mov"
end
@info "Selected video: $(video_name)"


video_streamer = VideoIO.open(video_path*video_name) # candle
video_streamer = VideoIO.open(video_path*"video_name.avi") # candle

video_array = []
video_file = VideoIO.openvideo(video_streamer,
                                        target_format=VideoIO.AV_PIX_FMT_GRAY8)



while !eof(video_file)
  img = read(video_file)

  img2 = rotate_around_center(img, 5pi/6)

  push!(video_array,img2)
end

close(video_file)
video_dimensions = get_video_dimension(video_array)


function rotate_around_center(img, angle = 5pi/6)
  θ = angle
  rot = recenter(RotMatrix(θ), [size(img)...] .÷ 2)  # a rotation around the center
  x_translation = 0
  y_translation = 0
  tform = rot ∘ Translation(y_translation, x_translation)
  img2 = warp(img, rot, axes(img))

  return img2
end




# TODO Generate video of rotating checkboard

# A solution for writing to a video file
# https://discourse.julialang.org/t/creating-a-video-from-a-stack-of-images/646/7
using Images

function writevideo(fname, imgstack::Array{<:Color,3};
                    overwrite=true, fps=30::UInt, options=``)
    ow = overwrite ? `-y` : `-n`
    h, w, nframes = size(imgstack)

    open(`ffmpeg
            -loglevel warning
            $ow
            -f rawvideo
            -pix_fmt rgb24
            -s:v $(h)x$(w)
            -r $fps
            -i pipe:0
            $options
            -vf "transpose=0"
            -pix_fmt yuv420p
            $fname`, "w") do out
        for i = 1:nframes
            write(out, convert.(RGB{N0f8}, clamp01.(imgstack[:,:,i])))
        end
    end
end

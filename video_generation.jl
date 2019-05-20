include("VideoManage.jl")

 ENV["JULIA_DEBUG"] = "all"


VIDEO = (diag_1=1,
           diag_2=2,
           diag_g1=3,
           diag_g2=4,
           diag_gb=5,
           diag_dbl=6,
           horiz=7)

choice = VIDEO.horiz
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
 @info "Selected video: '$(video_name)'"

rotate_and_save_video(video_path, video_name, "rot_$(video_name)")
rotate_and_save_video(video_path, "diag_strip_30sec_single_dbl_gaps.mov", "rot_diag_strip_30sec_single_dbl_gaps.mov")


##"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# """"""""""""""""""""""""""""Creation of new images"""""""""""""""""""""""""""

include("GifGenerator.jl")

path = "/home/ed19aaf/Programming/Julia/JuliaLearning/gif/"
gif_name = "sth2.gif"
gif_dims = (width = 600, height = 400, max_len = 360)

generate_gif(dotted_plane, path*gif_name, gif_dims)

img = load_gif_to_array

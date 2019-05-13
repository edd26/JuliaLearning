using Plots
 include("VideoManage.jl")

VIDEO = (diag_1=1,
            diag_2=2,
            diag_g1=3,
            diag_g2=4,
            diag_gb=5,
            diag_dbl=6,
            horiz=7)

choice = VIDEO.diag_gb
 tau_max = 5
 points_per_dim = 15;
 video_path = pwd()* "/videos/"

# for choice = 1:length(VIDEO)
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

#
video_array = get_video_array_from_file(video_path*video_name)
video_dimensions = get_video_dimension(video_array)
indicies_set = get_video_mask(points_per_dim, video_dimensions)
extracted_pixels = extract_pixels_from_video(video_array,
                                                indicies_set, video_dimensions)
vectorized_video = vectorize_video(extracted_pixels)
C_ij = get_pairwise_correlation_matrix(vectorized_video, tau_max)

# log_C_ij = map(log10, map(abs,C_ij))


heatmap(C_ij,  color=:lightrainbow, title="Cij, $choice, number of points: $points_per_dim")
# end

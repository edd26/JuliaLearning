using Plots

include("VideoManage.jl")
include("MatrixToolbox.jl")
include("clique_top_Julia/CliqueTop.jl")

VIDEO = (diag_1=1,
            diag_2=2,
            diag_g1=3,
            diag_g2=4,
            diag_gb=5,
            diag_dbl=6,
            horiz=7)

video_choice = VIDEO.diag_1

# TODO Automate videos listing in this file by sth linke ls *.mov
videos_names = ["diag_strip_30sec_1.mov",
                "diag_strip_30sec_2.mov",
                "diag_strip_30sec_gray_1.mov",
                "diag_strip_30sec_gray_2.mov",
                "diag_strip_30sec_gray_both.mov",
                "diag_strip_30sec_single_dbl_gaps.mov",
                "horiz_strip_30sec.mov"]

video_name = videos_names[video_choice]

video_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/videos/"
results_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/results_patch_average/"

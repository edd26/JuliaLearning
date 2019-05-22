using Plots
using Dates

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

# videos_names = ["diag_strip_30sec_1.mov",
#                 "diag_strip_30sec_2.mov",
#                 "diag_strip_30sec_gray_1.mov",
#                 "diag_strip_30sec_gray_2.mov",
#                 "diag_strip_30sec_gray_both.mov",
#                 "diag_strip_30sec_single_dbl_gaps.mov",
#                 "horiz_strip_30sec.mov"]



video_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/videos/"
results_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/results/"

session_number = Dates.value(Dates.now() - Dates.DateTime(Dates.today()))
session_name =  string(Dates.today()) * "-"*string(session_number)

current_path = pwd()
cd(results_path)
if !isdir(session_name)
    mkdir(results_path*session_name)
    # mkdir(results_path*session_name*"/clique_top")
    # mkdir(results_path*session_name*"/eirene")
    # mkdir(results_path*session_name*"/vectorized")
end

results_cliq = results_path*session_name*"/" # pwd()*"/clique_top"
results_eirene = results_path*session_name*"/" # pwd()*"/eirene"
results_vec = results_path*session_name*"/" # pwd()*"/vectorized"

cd(current_path)

videos_names = readdir(video_path)

# ---------------
testing_paramenters = Dict()
testing_paramenters["do_clique_top"] = true
testing_paramenters["do_eirene"] = false
# testing_paramenters["choice"] = VIDEO.diag_gb
testing_paramenters["save_figures"] = true
testing_paramenters["plot_betti_figrues"] = true
testing_paramenters["plot_vectorized_video"] = true
testing_paramenters["tau_max"] = 25
testing_paramenters["points_per_dim"] = 9
testing_paramenters["size_limiter"] = 20
testing_paramenters["use_testing_set"] = true
testing_paramenters["video_name"] = videos_names[video_choice]

# videos_set = [video_choice]
# tau_max_set = [testing_paramenters["tau_max"]]
# points_per_dim_set = [testing_paramenters["points_per_dim"]]

videos_set = [8 10]
tau_max_set = [5 10 20 25]
points_per_dim_set = [4 9 12]

# for video in videos_set
#     println(video)
# end

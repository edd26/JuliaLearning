using Plots
using Dates

include("TestingPairwiseCorrelationmatrix.jl.jl")


VIDEO = (diag_1=1,
            diag_2=2,
            diag_g1=3,
            diag_g2=4,
            diag_gb=5,
            diag_dbl=6,
            horiz=7)

DISTRIBUTION = (uniform="uniform",
                random="random",
                patch="patch",
                local_corr="local_corr")

video_choice = VIDEO.diag_1

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

results_cliq_path = results_path*session_name*"/" # pwd()*"/clique_top"
results_eirene_path = results_path*session_name*"/" # pwd()*"/eirene"
results_vec_path = results_path*session_name*"/" # pwd()*"/vectorized"

cd(current_path)

videos_names = readdir(video_path)

# ---------------
test_params = Dict()
test_params["do_clique_top"] = true
test_params["do_eirene"] = false
# test_params["choice"] = VIDEO.diag_gb
test_params["save_figures"] = true
test_params["plot_betti_figrues"] = true
test_params["plot_vectorized_video"] = true
test_params["tau_max"] = 25
test_params["points_per_dim"] = 9
test_params["size_limiter"] = 20
test_params["use_testing_set"] = true
test_params["video_name"] = videos_names[video_choice]
test_params["ind_distrib"] = DISTRIBUTION.uniform
test_params["shift_set"] = [2 4]

#TODO saving and loading from multiple files

# videos_set = [video_choice]
# tau_max_set = [test_params["tau_max"]]
# points_per_dim_set = [test_params["points_per_dim"]]

videos_set = [8 10]
tau_max_set = [5 10 20 25]
points_per_dim_set = [4 9 12]
shifts_set = [2 4]
patch_params = Dict("x"=>1, "y"=>1, "spread" =>1)

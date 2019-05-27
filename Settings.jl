using Dates
"""
This script contains the variables for the testing of the
    TestingPairwiseCorrelationmatrix script. All of them are stored int the
    test_params dictionary. The options are stored under follownig keys:
    - The boolean flags:
        * do_clique_top -
        * do_eirene -
        * save_figures -
        * plot_betti_figrues -
        * plot_vectorized_video -
        * create_new_sessions-
    - Matrix parameters
        * size_limiter -
        * ind_distrib -
        * patch_params -
    - Sets:
        * shift_set -
        * sub_img_size_set -
        * videos_set -
        * tau_max_set -
        * points_per_dim_set -
        * shifts_set -
    - Paths
        * video_path-
        * results_path-

"""

VIDEO = (diag_1=1,
            diag_2=2,
            diag_g1=3,
            diag_g2=4,
            diag_gb=5,
            diag_dbl=6,
            horiz=7,
            water=8,
            reef=9,
            candle=10,
            checkboard=11)

DISTRIBUTION = (uniform="uniform",
                random="random",
                patch="patch",
                local_corr="local_corr",
                local_grad="local_grad")

test_params = Dict()
test_params["do_clique_top"] = true
test_params["do_eirene"] = false
# test_params["choice"] = VIDEO.diag_gb
test_params["save_figures"] = true
test_params["plot_betti_figrues"] = true
test_params["plot_vectorized_video"] = true
test_params["create_new_sessions"] = true

# test_params["tau_max"] = 25 # may become obsolette due to the tau-set parameter
# test_params["points_per_dim"] = 9# may become obsolette due to the tau-set parameter
test_params["size_limiter"] = 40
# test_params["use_testing_set"] = true
# test_params["video_name"] = videos_names[video_choice] # may become obsolette due to the tau-set parameter
test_params["ind_distrib"] = DISTRIBUTION.local_grad
test_params["patch_params"] = Dict("x"=>1, "y"=>1, "spread" =>1)

test_params["shift_set"] = [2 4]
test_params["sub_img_size_set"] = [25 30]
test_params["videos_set"] = collect(1:length(videos_names))
test_params["tau_max_set"] = [50]
test_params["points_per_dim_set"] = [9]

execution_path = pwd()
test_params["video_path"] = execution_path*"/videos/"
test_params["results_path"] = execution_path*"/results/"

if test_params["create_new_sessions"]
    session_number = Dates.value(Dates.now() - Dates.DateTime(Dates.today()))
    session_name =  string(Dates.today()) * "-"*string(session_number)
    
    if !isdir(test_params["results_path"]*session_name)
        mkdir(test_params["results_path"]*session_name)
        # mkdir(results_path*session_name*"/clique_top")
        # mkdir(results_path*session_name*"/eirene")
        # mkdir(results_path*session_name*"/vectorized")
    end
    results_cliq_path = results_path*session_name*"/" # pwd()*"/clique_top"
    results_eirene_path = results_path*session_name*"/" # pwd()*"/eirene"
    results_vec_path = results_path*session_name*"/" # pwd()*"/vectorized"
else
    results_cliq_path = results_path*"/" # pwd()*"/clique_top"
    results_eirene_path = results_path*"/" # pwd()*"/eirene"
    results_vec_path = results_path*"/" # pwd()*"/vectorized"
end
videos_names = readdir(video_path)

# TODO The number of videos  in videos_names has to be controlled somehow
# TODO saving and loading from multiple files with JSON package
# TODO script for checking the dependencies (which may be stored in JSON file)
# TODO Add script for removing empty folders
# TODO add try-catch to the main manu which cathces dependency errors and then launches the script for dependency check

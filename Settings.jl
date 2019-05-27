using Dates
"""
This script contains the variables for the testing of the
    TestingPairwiseCorrelationmatrix script. All of them are stored int the
    test_params dictionary. The options are stored under follownig keys:
    - The boolean flags:
        * do_clique_top - enables/disables persistent homology computations with
            Julia version of MATLAB clique-top lirbary
        * do_eirene - enables/disables persistent homology computations with
            Eirene library
        * save_figures - enables/disables saving of figure in the results folder
        * plot_betti_figrues - enables/disables plotting Betti curves
        * plot_vectorized_video - enables/disables plotting of signals used for
            cross correlation matrix.
        * create_new_sessions- enables/disables creation of new folder with
            unique name in the resutls forlder for every run of this file.
    - Matrix parameters
        * size_limiter - reduces the number of rows and columns of pariwise
            correlation matrix for which the persistent homology is computed;
            the higher, the longer the computations (e.g. 88 will take
            approximately 40 mins to finish)
        * ind_distrib - takes values stored in the DISTRIBUTION named tuple;
            this parameters determines the way in which the pixels from frames
            are extracted; for details check the description of DISTRIBUTION
            variable.
        * patch_params - if "patch" distribution is selected, this variable is
            used to define the position of the first patch in the image (in the
            x and y valeus) as well as the spread between the patches.
    - Paths
        * video_path - path to the folder with videos for which betti curves
            will be computed.
        * results_path- path to the folder where the results will be saved.
    - Sets:
        * videos_names - list of all videos which are sotred under the
            @video_path
        * videos_set - array which values indicate which videos will be used in the testing procedure. The values indicate a position in the list of the videos, which is stored in the @videos_names
        * tau_max_set - set of values which are used as time shifts for
            computation of cross-correlation between signals
        * points_per_dim_set - set of values which determine the number of both
            columns and rows extracted from single frame;
        * shift_set - set of values which will be the shift of the initial
            window while computing local correlation; parameter used only for
            ind_distrib = {"local_corr"}
        * sub_img_size_set - size of an subimage; when one of the following
            distributions is chosen, ind_distrib = {"patch", "local_corr",
            "local_grad"}, not single pixels are extracted from an image, but a
            values which is computed based on the surroundings of the pixels;
            this parameters detemines the size of the surroundings.
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

test_params["tau_max_set"] = [50]
test_params["points_per_dim_set"] = [9]
test_params["shift_set"] = [2 4]
test_params["sub_img_size_set"] = [25 30]
test_params["videos_names"] = readdir(test_params["video_path"])
test_params["videos_set"] = collect(1:length(test_params["videos_names"]))


# TODO The number of videos  in videos_names has to be controlled somehow
# TODO saving and loading from multiple files with JSON package
# TODO script for checking the dependencies (which may be stored in JSON file)
# TODO Add script for removing empty folders
# TODO add try-catch to the main manu which cathces dependency errors and then launches the script for dependency check

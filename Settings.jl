"""
This script contains the variables for the testing of the
TestingPairwiseCorrelationmatrix script. All of them are stored int the
test_params dictionary.

NOTE: This procedure is applied to the videos. Every frame is converted
to grayscale. In order to copute pairwise correlation matrix,
set of cross correlations between signals needs to be obtained. A single
signal is a frame parameter at specific location in the frame whcih
varyies in time. The location and the method of frame parameter
extraction are determined by the DISTRIBUTION.

The options are stored under follownig keys:
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

Also, named tuples are created:
    * DISTRIBUTION - contains the information about how the signal source form
        a frame should be extracted;
        Possible options are:
        * uniform - pixel value is used as a parameter; pixels which are used
            as signal sources are distributed uniformly accross the columns and
            rows of a frame (thus they form a net spanned accross the frames in
            which distance between nods are equal);
        * random - pixel value is used as a parameter; distance between
            following pixels in a row and column are distributed randomly
            (created net has different distances between nods);
        * patch - the parameter is an average around the location of the pixel;
            the centers are distributed uniformly accross a frame; the size of
            a patch is desribed by the parameter stored in the
            test_params["sub_img_size_set"];
        * local_corr - the parameter is correlation of the subimage of size
            test_params["sub_img_size_set"] and the subimage of same size, but
            shifted by the values from range
            [-test_params["shift_set"]:test_params["shift_set"]] both for rows
            and columns; the size of a subimage is desribed by the parameter
            stored in the test_params["sub_img_size_set"].
        * local_grad - the parameters is a sum fo absolute values of gradients
            of the subimages (size= test_params["sub_img_size_set"]); the
            centers of the subimages are distribute unifromly accross the frame.
"""

using Dates

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
test_params["save_figures"] = true
test_params["plot_betti_figrues"] = true
test_params["plot_vectorized_video"] = true
test_params["create_new_sessions"] = true
test_params["size_limiter"] = 40
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


# TODO saving and loading from multiple files with JSON package
# TODO script for checking the dependencies (which may be stored in JSON file)
# TODO Add script for removing empty folders
# TODO add try-catch to the main manu which cathces dependency errors and then launches the script for dependency check

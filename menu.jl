include("Settings.jl")

function start_menu(;debug=false)
    # TODO check for dependencies and then inlude the settings
    if debug
        ENV["JULIA_DEBUG"] = "all"
    end

    println("------------------------------")
    println("Welcome to the main menu.")
    global leave = false
    while !leave
        println()
        println("--- Main menu ---")
        println("Please selecet the number from the list below")
        print_menu_items(main_menu_items)
        action = get_menu_item_from_usr(size(main_menu_items, 1))
        leave = execute_main_menu_action(action)
        halt = get_input_from_usr()
    end
    println("Good bye.")
end


function print_menu_items(menu_to_display)
    # menu_to_display = main_menu_items
    for element =1:size(menu_to_display,1)
        println("$element. "*menu_to_display[element])
    end
end

function get_menu_item_from_usr(max_range)
    @debug "Running get_menu_item_from_usr with param: " max_range
    usr_input = get_input_from_usr()
    action = validate_the_input(usr_input, max_range)
    return action
end

"""
 Gets the input from the console.

 Input is sent to the program after hiting enter.
 """
get_input_from_usr() = readline(stdin)

"""
 """
function validate_the_input(usr_input, max_range)
    @debug "Running validate_the_input with params: " usr_input, max_range
    usr_input = remove_dots(usr_input)
    action = -1
    try
        action = parse(Int, usr_input)

        if action > max_range
            println("Given number exceed the maximal range of the menu.")
            action = -1
        elseif action < 1
            println("Menu number must be positive Integer!")
            action = -1
        end
    catch err
        if isa(err, ArgumentError)
            println("Given input was not a number.")
        else
            println("An error has occurred while giving the input")
        end
        action = -1
    end
    @debug "Ending validation with action= " action
    return action
end

"""
 Removes dots from the input text.
 """
remove_dots(some_txt) = replace(some_txt, "."=>"")


function execute_main_menu_action(action )
    try
        if action == -1
            println("Given input is not valid for current menu.")
            println("Please try again.")
        elseif action == size(main_menu_items,1)
            println("Finishing the program.")
            return leave = true
        else
            main_menu_action[action]()
        end

    catch err
        if isa(err, ArgumentError)
            println("Sth went wrong")
        end
    end
    return leave = false
end


function launch_menu(menu_name)
    @debug "Running launch_menu with params: " menu_name
    run_menu = true
    title, elements, actions = menus_dict[menu_name]
    num_of_actions = size(actions , 1)
    @debug "num_of_actions = " num_of_actions

    println()
    println("------------------")
    while run_menu
        println("--- $(title) ---")
        println("Please selecet the number from the list below")
        print_menu_items(elements)

        action = get_menu_item_from_usr(num_of_actions)
        @debug "action = " action

        if action > 0  &&  action < num_of_actions
            actions[action]()
            halt = get_input_from_usr()
        elseif action == num_of_actions
            println("Procceding to prevoius menu.")
            run_menu = false
        end
    end
end

"""
 Empty function
 """
function proceed()
end

function print_path_info()
    println("Video path is set to:")
    println(video_path)
    println()
    println("Results path is set to:")
    println(results_path)
    println()
end

function launch_video_adjustment()
    launch_menu("video")
end

    function print_video_path_info()
        println("Video path is set to:")
        println(video_path)
        println()
    end

    function change_vid_path()
        while true
            ask_for_answer = true
            println("Please type new video folder path:")
            new_path = get_input_from_usr()

            if isdir(new_path)
                video_path = new_path
                println("New path was set succesfully.")
                ask_for_answer = false
                return
            else
                println("Given path does not exist.")

                while ask_for_answer
                    println("Do you want to try again? [y/n]")
                    decision = lowercase(get_input_from_usr())
                    if decision == "n"
                        println("Aborting changing of the video folder path.")
                        ask_for_answer = false
                        return
                    elseif decision == "y"
                        println("Let's try one more time.")
                        ask_for_answer = false
                    else
                        println("Please answer the question 'y' for yes and 'n' for no.")
                    end
                end #while ask_for_answer
            end #isdir
        end #while get_input_from_usr
    end #function

    function disp_loaded_file_name()
        println("Loaded file name is:")
        println(testing_paramenters["video_name"])
        println()
    end

# TODO remove this function as the test are done on set instead of this value
    function change_vid_from_list()
        @debug "Launching change_vid_from_list."
        println("Please select single number of the listed videos: ")
        action = choose_listed_video()
        @debug "Menu action from usr: " action

        if action > 0
            new_name = videos_names[action]
            @debug "new_name: " new_name
            @debug "isfile: " isfile(video_path*new_name)
            if isfile(video_path*new_name)
                delete!(testing_paramenters, "video_name")
                testing_paramenters["video_name"] = new_name
                @debug "The name was changed to: " testing_paramenters["video_name"]
                println("New file name was succesfully changed.")
            else
                println("Error occurred. File from the list can not be found at vieo path!")
            end
        else
            @debug action
        end
        @debug "New file name: " testing_paramenters["video_name"]
    end

# TODO same as above
    function change_vid_name()
        change = true
        ask_for_answer = true

        while change
            println("Please type new video name:")
            new_video = get_input_from_usr()

            if isfile(video_path*new_video)
                testing_paramenters["video_name"] = new_video
                println("New video was set succesfully.")
                ask_for_answer = false
                return
            else
                println("Given video does not exist at the current video location.")
                change = ask_for_repeat()
            end #isdir
        end #while get_input_from_usr
    end #function

function list_videos()
    number_of_videos = size(videos_names,1)
    for k =1:number_of_videos
        println("$(k). $(videos_names[k])")
    end
end

function choose_listed_video()
    number_of_videos = size(videos_names,1)
    list_videos()
    action = get_menu_item_from_usr(number_of_videos)
    return action
end

function ask_for_repeat()
    ask_for_answer = true
    while ask_for_answer
        println("Do you want to try again? [y/n]")
        decision = lowercase(get_input_from_usr())
        if decision == "n"
            println("Aborting changing of the variable.")
            ask_for_answer = false
            return contin = false
        elseif decision == "y"
            println("Let's try one more time.")
            ask_for_answer = false
            return contin = true
        else
            println("Please answer the question 'y' for yes and 'n' for no.")
        end
    end
end

function launch_testing()
    launch_menu("testing")
end

    function disp_testing_options()
        println("""
        Use clique-top library:                 $(testing_paramenters["do_clique_top"])
        Use Eirene library:                     $(testing_paramenters["do_eirene"])
        Selected video:                         $(testing_paramenters["video_name"])
        Plot Betti curves:                      $(testing_paramenters["plot_betti_figrues"])
        Plot vectorized video:                  $(testing_paramenters["do_clique_top"])
        Save figures:                           $(testing_paramenters["save_figures"])
        τ_max:                                  $(testing_paramenters["tau_max"])
        Number of points in mask:               $(testing_paramenters["points_per_dim"])
        Maximal size of pairwise corr. matrix:  $(testing_paramenters["size_limiter"])
        """)
        println("End of options")
    end

    function change_testing_params()
        println("Which parameters would you like to change?")
        ask_for_new_val = true

        k = 1
        for key in keys(testing_paramenters)
            if key != "video_name"
                println("$(k). $(key)")
                k += 1
            end
        end
        k -= 1
        choice = get_menu_item_from_usr(k)

        kk = 1
        for key in keys(testing_paramenters)
            if kk == choice
                choice_val = testing_paramenters[key]
                type = typeof(choice_val)

                while ask_for_new_val
                    println("Please give new value for the parameter.")
                    println("Note: it has to be of type: $(type)")
                    new_value = get_input_from_usr()
                    try
                        if type == Bool && (occursin("true", new_value) || occursin("false", new_value))
                            new_value = new_value == "true"
                            asserted = true

                        elseif type == Int
                            new_value = parse(Int, new_value)
                            asserted = true
                        elseif type == String
                            # Do not chagne anything
                            asserted = true
                        else
                            println("Changed parameter is not Bool, Int or String")
                            asserted = false
                        end

                        if asserted
                            @debug "New value of the parameters will be: " new_value
                            delete!(testing_paramenters, key)
                            testing_paramenters[key] = new_value
                            println("Succesfully changed the parameter to:")
                            println(testing_paramenters[key])
                            return
                        end
                    catch err
                        if isa(err, ArgumentError)
                            println("Given input cannot be parsed into type of selected variable")
                        end
                    end #try
                    println("Failed to change the parameter due to wrong type.")
                    ask_for_new_val = ask_for_repeat()
                end #ask_for_new_val
            end #if choice
            kk += 1
        end #for keys
    end #function

    function set_set(set_to_change)
        @debug "Launching set_set for: " set_to_change

        action = get_input_from_usr()
        @debug "Menu action from usr: " action

        action = remove_dots(action)
        set = split(action, " ")
        elements_in_set = size(set, 1)
        int_set = zeros(Int, elements_in_set)

        try
            for k = 1:elements_in_set
                int_set[k] = parse(Int, set[k])
            end
            set_to_change = int_set
            println("New testing set is set to: $(set_to_change).")
        catch err
            if isa(err, ArgumentError)
                println("Given input was not a Integer.")
            else
                println("An error has occurred while giving the input")
            end
        end
    end

    function set_videos_set()
        @debug "Launching set_videos_set."
        list_videos()
        println("Please select numbers of the listed videos.")
        println("Note: they should be separetaed with single space.")
        set_set(videos_set)
    end

    function set_tau_set()
        @debug "Launching set_tau_set."
        println("Please type tau values for which testing should be done.")
        println("Note: values should be separetaed with single space.")
        set_set(tau_max_set)
    end

    function set_points_per_dim_set_set()
        @debug "Launching set_points_per_dim_set_set."
        println("Please type points_per_dim_set values for which testing should be done.")
        println("Note: values should be separetaed with single space.")
        set_set(points_per_dim_set)
    end

    function launch_full_testing()
        println("Not yet implemented :(")
    end

    function launch_quick_testing()
        testing_function()
    end


main_menu_items = ["Print path information",
                    "Video file information and adjustments.",
                    "Launch testing.",
                    "Clear the console.",
                    "Exit program."]
main_menu_action = [print_path_info,
                    launch_video_adjustment,
                    launch_testing,
                    clearconsole]

video_menu_actions = [print_video_path_info,
                        change_vid_path,
                        disp_loaded_file_name,
                        change_vid_from_list,
                        change_vid_name,
                        proceed]
video_menu_items  = ["Display currennt video path.",
                        "Change video path.",
                        "Display loaded file name.",
                        "Choose video from list.",
                        "Change video file name.",
                        "Go to previous menu."]

testing_menu_actions = [disp_testing_options,
                change_testing_params,
                set_videos_set,
                set_tau_set,
                set_points_per_dim_set_set,
                launch_full_testing,
                launch_quick_testing,
                proceed]
testing_menu_items  = ["Display testing routine and parameters.",
            "Change the testing parameters.",
            "Set testing set.",
            "Set maxial tau values set.",
            "Set the number of points whcih will be extracted from the main matrix.",
            "Launch full testing (will ask and explain all parameters).",
            "Launch quick testing (uses set of currently set parameters).",
            "Go to previous menu."]

menus_dict = Dict()
menus_dict["main"] = ("Main Menu", main_menu_items, main_menu_action)
menus_dict["video"] = ("Video Menu", video_menu_items, video_menu_actions)
menus_dict["testing"] = ("Testing Menu", testing_menu_items, testing_menu_actions)

function testing_function()
    do_clique_top = testing_paramenters["do_clique_top"]
    do_eirene =     testing_paramenters["do_eirene"]
    save_figures = testing_paramenters["save_figures"]
    plot_betti_figrues = testing_paramenters["plot_betti_figrues"]
    plot_vectorized_video = testing_paramenters["plot_vectorized_video"]
    size_limiter = testing_paramenters["size_limiter"]


    @debug "do_clique_top: " do_clique_top

    function saving_figures(ref, path, video_name)
        name = split(video_name, ".")[1]
        name =  path * name *
                "_size$(size_limiter)_points$(points_per_dim)_tau$(tau_max).png"
        savefig(ref, name)

        @info "File saved: " name
    end

    @debug "All videos are: " videos_names
    @debug "Video set is : " videos_set
    for video in videos_set
        choice = videos_names[video]
        @info "Selected video: " choice

        @debug "Path and choice is:" video_path*choice
        video_array = get_video_array_from_file(video_path*choice)
        @info "Array extracted."

        video_dimensions = get_video_dimension(video_array)
        for points_per_dim in points_per_dim_set #TODO add end for this loop
            indicies_set = get_video_mask(points_per_dim, video_dimensions)
            @info "Mask extracted."

            extracted_pixels_matrix = extract_pixels_from_video(video_array, indicies_set, video_dimensions)
            @info "Pixels extracted."

            vectorized_video = vectorize_video(extracted_pixels_matrix)
            @info "Video is vectorized, proceeding to Pairwise correlation."

            for tau in tau_max_set
                ## Compute pairwise correlation
                C_ij = get_pairwise_correlation_matrix(vectorized_video, tau_max)

                # set the diagonal to zero
                for diag_elem in 1:size(C_ij,1)
                    C_ij[diag_elem,diag_elem] = 0
                end
                @info "Pairwise correlation finished, proceeding to persistance homology."

                # Compute persistance homology with CliqueTopJulia
                size_limiter = testing_paramenters["size_limiter"]
                @debug "using size limiter = " size_limiter

                if size_limiter > size(C_ij,1)
                    @warn "Used size limiter is larger than matrix dimension: " size_limiter size(C_ij,1)
                    @warn "Using maximal size instead"
                    size_limiter = size(C_ij,1)
                end

                @debug "do_clique_top: " do_clique_top
                @debug "testing_paramenters['do_clique_top']: " testing_paramenters["do_clique_top"]
                if do_clique_top
                    @debug pwd()
                    @time c_ij_betti_num, edge_density, persistence_intervals, unbounded_intervals = compute_clique_topology(C_ij[1:size_limiter, 1:size_limiter], edgeDensity = 0.6)
                end

                @debug "do_eirene: " do_eirene
                if do_eirene
                    C = eirene(C_ij[1:size_limiter, 1:size_limiter],maxdim=3,model="vr")
                end

                # --------------------------------------------------------------------
                # Plot results
                if plot_vectorized_video
                    vector_plot_ref = heatmap(vectorized_video, color=:grays)
                    if save_figures
                        name = split(video_name, ".")[1]
                        name = "vec_" * name * "_sz$(size_limiter)_p$(points_per_dim)_tau$(tau_max).png"
                        savefig(vector_plot_ref, name)
                    end #save vec
                end #plot vec

                if plot_betti_figrues && do_clique_top
                    betti_numbers = c_ij_betti_num
                    title = "Betti curves for pairwise corr. matrix"
                    p1 = plot_betti_numbers(c_ij_betti_num, edge_density, title);

                    heat_map1 = heatmap(C_ij,  color=:lightrainbow, title="Cij, $(video_name), number of points: $points_per_dim");

                    betti_plot_clq_ref = plot(p1, heat_map1, layout = (2,1))

                    if save_figures
                        saving_figures(betti_plot_clq_ref, results_cliq, video_name)
                    end#save fig
                end #plot cliq

                if plot_betti_figrues && do_eirene
                    betti_0 = betticurve(C, dim=0)
                    betti_1 = betticurve(C, dim=1)
                    betti_2 = betticurve(C, dim=2)
                    betti_3 = betticurve(C, dim=3)

                    title = "Betti curves for pairwise corr. matrix"

                    p1 = plot(betti_0[:,1], betti_0[:,1], label="beta_0", title=title)
                    #, ylims = (0,maxy)
                    plot!(betti_1[:,1], betti_1[:,2], label="beta_1")
                    plot!(betti_2[:,1], betti_2[:,2], label="beta_2")
                    plot!(betti_3[:,1], betti_3[:,2], label="beta_3")

                    heat_map1 = heatmap(C_ij,  color=:lightrainbow, title="Cij, $(video_name), number of points: $points_per_dim");

                    betti_plot_ei_ref = plot(p1, heat_map1, layout = (2,1))

                    if save_figures
                        saving_figures(betti_plot_ei_ref, results_eirene, video_name)
                    end#save fig
                end #plot eirene
            end #for tau
        end #for points_per_dim
    end #for video set
end #func

# TODO test functionality
# TODO test saving files
# TODO add different types of choosing values from matrix {uniform, random, patch}
# TODO Add listing of the sets
# TODO Remove setting the file name
# TODO Do testing function testing as it crashes

start_menu(debug=true)

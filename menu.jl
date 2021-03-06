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
        else
            @error "An error occured during execution of main menu function"
            println(err)
            throw(err)
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
    print_video_path_info()
    println("Results path is set to:")
    println(results_path)
    println()
end

function launch_video_adjustment()
    launch_menu("video")
end

    function print_video_path_info()
        println("Video path is set to:")
        println(test_params["video_path"])
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

    # function disp_loaded_file_name()
    #     println("Loaded file name is:")
    #     println(test_params["video_name"])
    #     println()
    # end

# TODO remove this function as the test are done on set instead of this value
    # function change_vid_from_list()
    #     @debug "Launching change_vid_from_list."
    #     println("Please select single number of the listed videos: ")
    #     action = choose_listed_video()
    #     @debug "Menu action from usr: " action
    #
    #     if action > 0
    #         new_name = videos_names[action]
    #         @debug "new_name: " new_name
    #         @debug "isfile: " isfile(video_path*new_name)
    #         if isfile(video_path*new_name)
    #             delete!(test_params, "video_name")
    #             test_params["video_name"] = new_name
    #             @debug "The name was changed to: " test_params["video_name"]
    #             println("New file name was succesfully changed.")
    #         else
    #             println("Error occurred. File from the list can not be found at vieo path!")
    #         end
    #     else
    #         @debug action
    #     end
    #     @debug "New file name: " test_params["video_name"]
    # end

# TODO same as above
    function change_vid_name()
        change = true
        ask_for_answer = true

        while change
            println("Please type new video name:")
            new_video = get_input_from_usr()

            if isfile(video_path*new_video)
                test_params["video_name"] = new_video
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
        Use clique-top library:                 $(test_params["do_clique_top"])
        Use Eirene library:                     $(test_params["do_eirene"])

        Plot Betti curves:                      $(test_params["plot_betti_figrues"])
        Plot vectorized video:                  $(test_params["do_clique_top"])
        Save figures:                           $(test_params["save_figures"])

        Number of points in mask:               $(test_params["points_per_dim"])
        Maximal size of pairwise corr. matrix:  $(test_params["size_limiter"])
        """) # τ_max:                                  $(test_params["tau_max"])         Selected video:                         $(test_params["video_name"])
        println("End of options")
    end

    function change_testing_params()
        println("Which parameters would you like to change?")
        ask_for_new_val = true

        k = 1
        for key in keys(test_params)
            if key != "video_name"
                println("$(k). $(key)")
                k += 1
            end
        end
        k -= 1
        choice = get_menu_item_from_usr(k)

        kk = 1
        for key in keys(test_params)
            if kk == choice
                choice_val = test_params[key]
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
                            delete!(test_params, key)
                            test_params[key] = new_value
                            println("Succesfully changed the parameter to:")
                            println(test_params[key])
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
        testing_pariwise_corr()
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
            "Set maximal tau values set.",
            "Set the number of points whcih will be extracted from the main matrix.",
            "Launch full testing (will ask and explain all parameters).",
            "Launch quick testing (uses set of currently set parameters).",
            "Go to previous menu."]

menus_dict = Dict()
menus_dict["main"] = ("Main Menu", main_menu_items, main_menu_action)
menus_dict["video"] = ("Video Menu", video_menu_items, video_menu_actions)
menus_dict["testing"] = ("Testing Menu", testing_menu_items, testing_menu_actions)


# TODO add different types of choosing values from matrix {uniform, random, patch}
# TODO Add listing of the sets
# TODO Remove setting the file name
# TODO Add new settings to the menu functionality
# TODO Add shifts to set up menu
# TODO Ask to change the index distribution if shift set was changed.
start_menu(debug=true)

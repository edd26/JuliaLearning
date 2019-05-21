include("Settings.jl")

main_menu_items = ["Print path information",
                    "Video file information and adjustments.",
                    "Launch testing.",
                    "Clear the console.",
                    "Exit program."]

video_menu = ["Display currennt video path.",
                        "Change video path.",
                        "Display loaded file name.",
                        "Choose video from list.",
                        "Change video file name.",
                        "Go to previus menu."]

testing_menu = ["Display testing routine and parameters.",
                "Change the testing parameters",
                "Start testing.",
                "Go to previus menu."]

function start_menu()
    # push!(video_menu, "0. ")
    # push!(testing_menu, "0. Go to previus menu.")

    println("----------------------")
    println("Welcome to the main menu.")
    global leave = false
    while !leave
        println()
        println("--- Main menu ---")
        println("Please selecet the number from the list below")
        print_menu_items(main_menu_items)
        action = get_menu_item_from_usr(size(main_menu_items, 1))
        leave = execute_main_menu_action(action)
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

function print_path_info()
    println("Video path is set to:")
    println(video_path)
    println()
    println("Results path is set to:")
    println(results_path)
    println()
end

function launch_video_adjustment()
    adjust_video_settings = true
    println()
    println("-------------")
    while adjust_video_settings
        println("--- Video menu ---")
        println("Please selecet the number from the list below")
        print_menu_items(video_menu)
        action = get_menu_item_from_usr(size(video_menu, 1))
        if action > 0  &&  action <= size(video_menu, 1)
            video_menu_actions[action]()
        elseif action > 0
            println("Procceding to prevoius menu.")
            adjust_video_settings = false
        end
    end
end

function launch_testing()
    println("launch_testing")
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
    println(videos_names[video_choice])
    println()
end

function change_vid_from_list()
    println("Please select number of the list of videos:")

    number_of_videos = size(videos_names,1)
    for k =1:number_of_videos
        println("$(k). $(videos_names[k])")
    end
    action = get_menu_item_from_usr(number_of_videos)

    if action > 0
        new_name = videos_names[action]
        if isfile(video_path*new_name)
            video_name = new_name
            println("New file name was succesfully changed.")
        else
            println("Error occurred. File from the list can not be found at vieo path!")
        end
    end
end

function change_vid_name()
    while true
        ask_for_answer = true
        println("Please type new video name:")
        new_video = get_input_from_usr()

        if isfile(video_path*new_video)
            video_name = new_video
            println("New video was set succesfully.")
            ask_for_answer = false
            return
        else
            println("Given video does not exist at the current video location.")

            while ask_for_answer
                println("Do you want to try again? [y/n]")
                decision = lowercase(get_input_from_usr())
                if decision == "n"
                    println("Aborting changing of the video name.")
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

main_menu_action = [print_path_info,
                    launch_video_adjustment,
                    launch_testing,
                    clearconsole]

video_menu_actions = [print_video_path_info,
                        change_vid_path,
                        disp_loaded_file_name,
                        change_vid_from_list,
                        change_vid_name]

testing_menu_actions = ["Display testing routine and parameters.",
                "Change the testing parameters",
                "Start testing."]

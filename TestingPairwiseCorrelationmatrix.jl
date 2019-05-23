using Eirene
include("clique_top_Julia/CliqueTop.jl")
include("VideoProcessing.jl")
include("MatrixToolbox.jl")

function saving_figures(ref, path, choice, points_per_dim, tau)
    name = split(choice, ".")[1]
    name =  path * name *
            "_size$(size_limiter)_points$(points_per_dim)_tau$(tau).png"
    savefig(ref, name)

    @info "File saved: " name
end

function  plot_eirene_betti_curves(C, C_ij)
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

    heat_map1 = heatmap(C_ij,  color=:lightrainbow, title="Cij, $(choice), number of points: $points_per_dim");
end

function testing_pariwise_corr()
    do_clique_top = test_params["do_clique_top"]
    do_eirene =     test_params["do_eirene"]
    save_figures = test_params["save_figures"]
    plot_betti_figrues = test_params["plot_betti_figrues"]
    plot_vectorized_video = test_params["plot_vectorized_video"]
    size_limiter = test_params["size_limiter"]
    ind_distrib = test_params["ind_distrib"]
    do_local_corr = false

    if ind_distrib = "local_corr" || ind_distrib = "local_grad"
        shift_set = test_params["shift_set"]
        sub_img_size_set = test_params["sub_img_size_set"]
        do_local_corr = true
    else
        shift_set = [1]
        sub_img_size_set = [9]
        do_local_corr = false
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
        for points_per_dim in points_per_dim_set
            for shift in shift_set, sub_img_size in sub_img_size_set
                if do_local_corr
                    sub_img_size = points_per_dim
                    start_ind = ceil(Int, points_per_dim/2) + shift
                    last_ind = video_dimensions.video_height - start_ind

                    set = broadcast(floor, Int, range(start_ind, stop=last_ind,  length=points_per_dim))
                    centers = [set set]'

                    extracted_pixels_matrix = get_local_total_correlations(video_array, centers, sub_img_size, shift)
                else
                    indicies_set = get_video_mask(points_per_dim, video_dimensions,  distribution=ind_distrib, patch_params)

                    extracted_pixels_matrix = extract_pixels_from_video(video_array, indicies_set, video_dimensions)
                end
                @info "Pixels extracted."

                vectorized_video = vectorize_video(extracted_pixels_matrix)
                @info "Video is vectorized, proceeding to Pairwise correlation."

                for tau in tau_max_set
                    ## Compute pairwise correlation
                    C_ij = get_pairwise_correlation_matrix(vectorized_video, tau)

                    # set the diagonal to zero
                    for diag_elem in 1:size(C_ij,1)
                        C_ij[diag_elem,diag_elem] = 0
                    end
                    @info "Pairwise correlation finished, proceeding to persistance homology."

                    # Compute persistance homology with CliqueTopJulia
                    size_limiter = test_params["size_limiter"]
                    @debug "using size limiter = " size_limiter

                    if size_limiter > size(C_ij,1)
                        @warn "Used size limiter is larger than matrix dimension: " size_limiter size(C_ij,1)
                        @warn "Using maximal size instead"
                        size_limiter = size(C_ij,1)
                    end

                    @debug "do_clique_top: " do_clique_top
                    @debug "test_params['do_clique_top']: " test_params["do_clique_top"]
                    if do_clique_top
                        @debug pwd()
                        @time c_ij_betti_num, edge_density, persistence_intervals, unbounded_intervals = compute_clique_topology(C_ij[1:size_limiter, 1:size_limiter], edgeDensity = 0.6)
                    end

                    @debug "do_eirene: " do_eirene
                    if do_eirene
                        C = eirene(C_ij[1:size_limiter, 1:size_limiter],maxdim=3,model="vr")
                    end

                    # ---------------------------------------------------------
                    # Plot results
                    @debug "Proceeding to plotting."
                    if plot_vectorized_video
                        vector_plot_ref = heatmap(vectorized_video, color=:grays)
                        if save_figures
                            name = split(choice, ".")[1]
                            name = "vec_" * name * "_sz$(size_limiter)_p$(points_per_dim)_tau$(tau).png"
                            savefig(vector_plot_ref, name)
                        end #save vec
                    end #plot vec

                    if plot_betti_figrues && do_clique_top
                        betti_numbers = c_ij_betti_num
                        title = "Betti curves for pairwise corr. matrix"
                        p1 = plot_betti_numbers(c_ij_betti_num, edge_density, title);

                        heat_map1 = heatmap(C_ij,  color=:lightrainbow, title="Pariwise Correlation matrix, number of points: $(points_per_dim)");

                        betti_plot_clq_ref = plot(p1, heat_map1, layout = (2,1))

                        if save_figures
                            saving_figures(betti_plot_clq_ref, results_cliq_path, choice, points_per_dim, tau)
                        end#save fig
                    end #plot cliq

                    if plot_betti_figrues && do_eirene
                        p1, heat_map1 = plot_eirene_betti_curves(C, C_ij)
                        betti_plot_ei_ref = plot(p1, heat_map1, layout = (2,1))

                        if save_figures
                            saving_figures(betti_plot_ei_ref, results_cliq_path, choice, points_per_dim, tau)
                        end#save fig
                    end #plot eirene
                end #for tau
            end #for shift
        end #for points_per_dim
    end #for video set
end #func

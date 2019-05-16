using Plots
 using MATLAB
 using Eirene
 include("VideoManage.jl")
 include("GeometricMatrix.jl")
 include("clique_top_Julia/CliqueTop.jl")


function doit(;do_clique_top = false,
               do_eirene = true,
               choice = VIDEO.diag_gb,
               save_figures = true,
               plot_all_figrues = true,
               tau_max = 5,
               points_per_dim = 9)

   VIDEO = (diag_1=1,
               diag_2=2,
               diag_g1=3,
               diag_g2=4,
               diag_gb=5,
               diag_dbl=6,
               horiz=7)
   video_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/videos/"
   results_path = "/home/ed19aaf/Programming/Julia/JuliaLearning/results/"
   results_eirene = "/home/ed19aaf/Programming/Julia/JuliaLearning/results_eirene/"
    # inverse = -1

   #    inverse = inverse*(-1)
   for choice = 1:7
   # for tau = 10
      # -----------------------------------------------------------------------------
       ## Process Image
       if choice == VIDEO.diag_1
          video_name = "diag_strip_30sec_1.mov"
       elseif choice == VIDEO.diag_2
          video_name = "diag_strip_30sec_2.mov"
       elseif choice == VIDEO.diag_g1
          video_name = "diag_strip_30sec_gray_1.mov"
       elseif choice == VIDEO.diag_g2
          video_name = "diag_strip_30sec_gray_2.mov"
       elseif choice == VIDEO.diag_gb
          video_name = "diag_strip_30sec_gray_both.mov"
       elseif choice == VIDEO.diag_dbl
          video_name = "diag_strip_30sec_single_dbl_gaps.mov"
       elseif choice == VIDEO.horiz
          video_name = "horiz_strip_30sec.mov"
       end
       println("Selected video: $(video_name)")

      video_array = get_video_array_from_file(video_path*video_name)
      video_dimensions = get_video_dimension(video_array)
      indicies_set = get_video_mask(points_per_dim, video_dimensions)
      extracted_pixels_matrix = extract_pixels_from_video(video_array, indicies_set, video_dimensions)
      vectorized_video = vectorize_video(extracted_pixels_matrix)
      println("Video is vectorized, proceeding to Pairwise correlation.")


      # -----------------------------------------------------------------------------
      ## Compute pairwise correlation
      C_ij = get_pairwise_correlation_matrix(vectorized_video, tau_max)
      # log_C_ij = map(log10, map(abs,C_ij))

      # set the diagonal to zero
      for diag_elem in 1:size(C_ij,1)
         C_ij[diag_elem,diag_elem] = 0
      end


      println("Pairwise correlation is finished, proceeding to persistance homology.")

      if do_clique_top
         # -----------------------------------------------------------------------------
         # Compute persistance homology with CliqueTopJulia
         size_limiter = 40 # size(C_ij,1)

         ## Copute persistance homology with the Julia version of clique-top library
         @time c_ij_betti_num, edge_density, persistence_intervals, unbounded_intervals =
                           compute_clique_topology(C_ij[1:size_limiter, 1:size_limiter],
                                                   edgeDensity = 0.8)

         # --------------------------------------------------------------------
         # Plot results
         if plot_all_figrues
            betti_numbers = c_ij_betti_num
            title = "Betti curves for pairwise correlation matrix, matrix size $size_limiter"
            p1 = plot_betti_numbers(c_ij_betti_num, edge_density, title);


            heat_map1 = heatmap(C_ij,  color=:lightrainbow, title="Cij, $(video_name), number of points: $points_per_dim");

            final_plot_ref = plot(p1, heat_map1, layout = (2,1))
            # plot(p1, heat_map1, layout = (2))
         end

         if save_figures
            cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
            name = split(video_name, ".")[1]
            savefig(final_plot_ref, results_path*name*"_size$(size_limiter)"*"_tau$(tau_max)"*".png")
         end
      end

   ## --------------------------------------------------------
   # Copute persistance homology with the Eirene library
      if do_eirene
         size_limiter = size(C_ij,1)

         C = eirene(C_ij[1:size_limiter, 1:size_limiter],maxdim=3,model="vr")
         # plotpersistencediagram_pjs(C,dim=1)


         if plot_all_figrues
            betti_0 = betticurve(C, dim=0)
            betti_1 = betticurve(C, dim=1)
            betti_2 = betticurve(C, dim=2)
            betti_3 = betticurve(C, dim=3)

            title = "Betti curves for pairwise correlation matrix, matrix size $size_limiter"

            p1 = plot(betti_0[:,1], betti_0[:,1], label="beta_0", title=title)
             #, ylims = (0,maxy)
            plot!(betti_1[:,1], betti_1[:,2], label="beta_1")
            plot!(betti_2[:,1], betti_2[:,2], label="beta_2")
            plot!(betti_3[:,1], betti_3[:,2], label="beta_3")

            heat_map1 = heatmap(C_ij,  color=:lightrainbow, title="Cij, $(video_name), number of points: $points_per_dim");

            final_plot_ref = plot(p1, heat_map1, layout = (2,1))
         end

         if save_figures
            cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
            name = split(video_name, ".")[1]
            savefig(final_plot_ref, results_eirene*name*"_size$(size_limiter)"*"_tau$(tau_max)"*".png")

            println("File saved.")
         end
      end
   end
end


## Test code for Eirene

## generate random matrix for comparison
random_matrix = generate_random_matrix(40)

ran_betti_num, edgeDensities, persistenceIntervals, unboundedIntervals =
         compute_clique_topology(random_matrix)
R = eirene(random_matrix,maxdim=3,model="vr")

p1 = plot_betti_numbers(ran_betti_num, edgeDensities, "Random  matrix clique top");
# %%
betti_0 = betticurve(R, dim=0)
betti_1 = betticurve(R, dim=1)
betti_2 = betticurve(R, dim=2)
betti_3 = betticurve(R, dim=3)

p2 = plot(betti_0[:,1], betti_0[:,1], label="beta_0", title="Random matrix Eirene"); #, ylims = (0,maxy)
plot!(betti_1[:,1], betti_1[:,2], label="beta_1");
plot!(betti_2[:,1], betti_2[:,2], label="beta_2");
plot!(betti_3[:,1], betti_3[:,2], label="beta_3");

plot_ref = plot(p1, p2, layout = (2,1))

cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
savefig(plot_ref, "results/comparison_random_matrix.png")







## Generate geometric matrix for comparison
random_matrix = readdlm( "geometric_matrix.csv", ',', Float64, '\n')
size = 70
random_matrix = random_matrix[1:size, 1:size]
ran_betti_num, edgeDensities, persistenceIntervals, unboundedIntervals =
         compute_clique_topology(random_matrix)
R = eirene(random_matrix,maxdim=3,model="vr")

p1 = plot_betti_numbers(ran_betti_num, edgeDensities, "Geometric matrix clique top, size $size");
# %%
betti_0 = betticurve(R, dim=0)
betti_1 = betticurve(R, dim=1)
betti_2 = betticurve(R, dim=2)
betti_3 = betticurve(R, dim=3)

p2 = plot(betti_0[:,1], betti_0[:,1], label="beta_0", title="Geometric matrix Eirene, size $size"); #, ylims = (0,maxy)
plot!(betti_1[:,1], betti_1[:,2], label="beta_1");
plot!(betti_2[:,1], betti_2[:,2], label="beta_2");
plot!(betti_3[:,1], betti_3[:,2], label="beta_3");

plot_ref = plot(p1, p2, layout = (2,1))

cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
savefig(plot_ref, "results/comparison_geometric_matrix.png")

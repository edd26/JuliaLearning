using Plots
 using MATLAB
 using Eirene
 using Random
 using Distances

include("clique_top_Julia/CliqueTop.jl")

# Setting seed for repetitive results
Random.seed!(1234)
    rand(1)

    # generate random matrix for comparison
    matrix_size = 60

    # Generate symetric random matrix
    elemnts_above_diagonal = Int((matrix_size^2-matrix_size)/2)
    random_matrix = zeros(matrix_size, matrix_size)
    set_of_random_numbers = rand(elemnts_above_diagonal)
    h = 1
    for k in 1:matrix_size
        for m in k+1:matrix_size
            random_matrix[k,m] = set_of_random_numbers[h]
            random_matrix[m,k] = set_of_random_numbers[h]
            global h += 1
        end
    end

    # Generate geometric matrix from uniformly distributed points in R^dim
    dim = 4
    number_of_points = matrix_size
    # Every column is a point, every row is coordinate in k-th dimension, k<=dim
    random_points = rand(Float64, dim, number_of_points)
    geometric_matrix = pairwise(Euclidean(), random_points, dims=2)

    # Eirene computations
    rand_result_eirene = eirene(random_matrix,maxdim=3,model="vr")
    geom_result_eirene = eirene(geometric_matrix,maxdim=3,model="vr")

# clique-top computations
mat"addpath('clique-top')"
mat"[A, B, C, D] = compute_clique_topology($random_matrix, 'Algorithm', 'split');"
mat"""$rand_betti_num = A;
 $edgeDensities_r = B;
 $persistenceIntervals = C;
 $unboundedIntervals = D;"""
mat"[A, B, C, D] = compute_clique_topology($geometric_matrix, 'Algorithm', 'split');"
mat"""$geom_betti_num = A;
 $edgeDensities_g = B;
 $persistenceIntervals = C;
 $unboundedIntervals = D;"""
# ran_betti_num, edgeDensities_r, persistenceIntervals, unboundedIntervals =
#                                         compute_clique_topology(random_matrix)
# geo_betti_num, edgeDensities_g, persistenceIntervals, unboundedIntervals =
#                                     compute_clique_topology(geometric_matrix)

# Eirene plotting
betti_rand_0 = betticurve(rand_result_eirene, dim=0)
    betti_rand_1 = betticurve(rand_result_eirene, dim=1)
    betti_rand_2 = betticurve(rand_result_eirene, dim=2)
    betti_rand_3 = betticurve(rand_result_eirene, dim=3)

    betti_geom_0 = betticurve(geom_result_eirene, dim=0)
    betti_geom_1 = betticurve(geom_result_eirene, dim=1)
    betti_geom_2 = betticurve(geom_result_eirene, dim=2)
    betti_geom_3 = betticurve(geom_result_eirene, dim=3)

    title="Random matrix, Eirene"
    p_rand_e = plot(betti_rand_0[:,1], betti_rand_0[:,1], label="beta_0",
                                title=title, xlims = (0,0.62), legend=:topleft);
    plot!(betti_rand_1[:,1], betti_rand_1[:,2], label="beta_1");
    plot!(betti_rand_2[:,1], betti_rand_2[:,2], label="beta_2");
    plot!(betti_rand_3[:,1], betti_rand_3[:,2], label="beta_3");

    title="Geometric matrix, Eirene"
    p_geom_e = plot(betti_geom_1[:,1], betti_geom_1[:,1], label="beta_0",
                                title=title, xlims = (0,0.62), legend=:topleft);
    plot!(betti_geom_1[:,1], betti_geom_1[:,2], label="beta_1");
    plot!(betti_geom_2[:,1], betti_geom_2[:,2], label="beta_2");
    plot!(betti_geom_3[:,1], betti_geom_3[:,2], label="beta_3");

# clique-top plotting
title = "Random  matrix, clique-top"
p_rand_ct = plot(edgeDensities_r[:], rand_betti_num[:,1], label="beta_0",
                                                title=title, legend=:topleft);
plot!(edgeDensities_r[:], rand_betti_num[:,2], label="beta_1");
plot!(edgeDensities_r[:], rand_betti_num[:,3], label="beta_2");

title = "Geometric  matrix, clique-top"
p_geom_ct = plot(edgeDensities_g[:], geom_betti_num[:,1], label="beta_0",
                                                title=title, legend=:topleft);
plot!(edgeDensities_g[:], geom_betti_num[:,2], label="beta_1");
plot!(edgeDensities_g[:], geom_betti_num[:,3], label="beta_2");

# Comparison plot
plot_ref1 = plot(p_rand_ct, p_rand_e, layout = (2,1))
plot_ref2 = plot(p_geom_ct, p_geom_e, layout = (2,1))

# savefig(plot_ref, "results/comparison_random_matrix.png")
#

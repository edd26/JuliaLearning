using MATLAB
 using DelimitedFiles
 using Plots
 include("GeometricMatrix.jl")
 include("clique_top_Julia/clique_top.jl")

geometric_matrix = readdlm( "geometric_matrix.csv", ',', Float64, '\n')

shuffeled_matrix = readdlm( "shuffeled_matrix.csv",  ',', Float64, '\n')
 random_matrix = readdlm( "random_matrix.csv",  ',', Float64, '\n')

ending = 40

println("Computing betti numbers for geometric matrix with $(ending)x$ending matrix.")
 # mat"$geom_betti_numbers = compute_clique_topology($geometric_matrix(1:$ending, 1:$ending), 'Algorithm', 'split');"

# TODO ERROR: UndefVarError: bettiCurves not defined
@time bettiCurves, edgeDensities, persistenceIntervals, unboundedIntervals = compute_clique_topology(geometric_matrix[1:ending, 1:ending])

println("Computing betti numbers for random matrix with $(ending)x$ending matrix.")
 mat"$rand_betti_numbers = compute_clique_topology($random_matrix(1:$ending, 1:$ending), 'Algorithm', 'split');"

println("Computing betti numbers for shuffled matrix with $(ending)x$ending matrix.")
 mat"$shuf_betti_numbers = compute_clique_topology($shuffeled_matrix(1:$ending, 1:$ending), 'Algorithm', 'split');"


save_matrix_to_file(geom_betti_numbers, "geometric_betties_$ending.csv")
save_matrix_to_file(rand_betti_numbers, "random_betties_$ending.csv")
save_matrix_to_file(shuf_betti_numbers, "shuffled_betties_$ending.csv")

plot_betti_numbers(geom_betti_numbers, "Geometric  matrix, matrix size $ending")
plot_betti_numbers(rand_betti_numbers, "Random  matrix, matrix size $ending")
plot_betti_numbers(shuf_betti_numbers, "Shuffled  matrix, matrix size $ending")

using ComputationalHomology
    using Distances
    using DataFrames
    using Random
    using DelimitedFiles
    using Plots

include("../MatrixToolbox.jl")
#= ############################################################################
    Example from library
=#

X = rand(3,10); # generate dataset
cplx, w = vietorisrips(X, 0.4, true) # generate Vietoris-Rips (VR) complex
flt = filtration(cplx, w) # construct filtration complex from VR complex

# following version does not work:
 # ph = persistenthomology(flt, TwistReduction)

# create persistent homology object with specific computation method
ph = persistenthomology(flt)

group(ph, 0) # calculate 0-homology group
group(ph, 1) # calculate 1-homology group
#= ############################################################################
    Own tests

    It is working, but is working very slow
=#
N = 100
dimensions = 5

Random.seed!(1234)

random_points = generate_random_point_cloud(N, dimensions)
geometric_matrix = generate_geometric_matrix(random_points)
matrix_ordering =  generate_matrix_ordering(geometric_matrix)
set_of_graphs, edge_density = generate_set_of_graphs(N, matrix_ordering)
# geometric_matrix = -geometric_matrix

# %% markdown
# # At his point, input matrix is assumed to be settled (either random,
# geometric or correaltion)
# Now Betti curves should be obtained by:
# 0. Creae set of graphs
# 1. Compute simplicial homology groups of the taken (i+1)-clique
# 2. Compute edge density (used later as abscissa)
# 3. Compute Betti number (used later as ordinate)
# %%


# function do_filtration(m)
points_filtration = zeros(Int, N)
    betti_number = zeros(3, size(matrix_ordering)[2])
    ordering_size = size(matrix_ordering)[2]

for k=1:Int(floor(ordering_size/20)):ordering_size
    points_filtration[matrix_ordering[1,k]] += 1
    points_filtration[matrix_ordering[2,k]] += 1

    mask = map(x -> x>=1, points_filtration)
    subset_of_points = random_points[:,mask]

    max_distance = geometric_matrix[matrix_ordering[1,k], matrix_ordering[2,k]]

    cplx, w = vietorisrips(subset_of_points, max_distance, true) # generate Vietoris-Rips (VR) complex
    flt = filtration(cplx, w) # construct filtration complex from VR complex
    ph = persistenthomology(flt) # create persistent homology object with specific computation method

    try
        for d in 0:2
            betti_number[d+1, k] = group(ph, d)
        end
    catch error

    end

    if mod(k,10)==1
        println(k)
    end
end


plot(edge_density, betti_number[1,:]);
 plot!(edge_density, betti_number[2,:]);
 plot!(edge_density, betti_number[3,:])

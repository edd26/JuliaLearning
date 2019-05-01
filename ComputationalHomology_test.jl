
using ComputationalHomology
    using Distances
    using DataFrames
    using Random

include("GeometricMatrix.jl")


N = 12
dimensions = 3

random_points = generate_random_point_cloud(N, dimensions)
geometric_matrix = generate_geometric_matrix(random_points)
matrix_ordering =  generate_matrix_ordering(geometric_matrix, N)
set_of_graphs = generate_set_of_graphs(N, matrix_ordering)

# %% markdown
# # At his point, input matrix is assumed to be settled (either random, geometric or correaltion)
# Now Betti curves should be obtained by:
# 0. Creae set of graphs
# 1. Compute simplicial homology groups of the taken (i+1)-clique
# 2. Compute edge density (used later as abscissa)
# 3. Compute Betti number (used later as ordinate)
# %%

filtration_mask = zeros(Int, size(random_points))
betti_number = zeros(3, N)

max_distance = findmin(geometric_matrix)
max_distance = -max_distance[1]

function do_filtration(k)
    filtration_mask[:, matrix_ordering[1,k]] .+= 1
    filtration_mask[:, matrix_ordering[2,k]] .+= 1

    mask = map(x -> x==1, filtration_mask[1,:])
    subset_of_points = random_points[:,mask]

    # println(subset_of_points)
    cplx, w = vietorisrips(subset_of_points, max_distance, true) # generate Vietoris-Rips (VR) complex
    println(cplx)
    flt = filtration(cplx, w) # construct filtration complex from VR complex
    flt.total
    ph = persistenthomology(flt) # create persistent homology object with specific computation method
    println(ph)


    # %%

    # if k == 1
    #     for dim in 0:1
    #         betti_number[dim+1, k] = group(ph, dim)
    #     end
    # else
    #     for dim in 0:2
    #         betti_number[dim+1, k] = group(ph, dim)
    #     end
    # end
end

do_filtration(1)
do_filtration(2)
do_filtration(3)
do_filtration(4)
do_filtration(5)

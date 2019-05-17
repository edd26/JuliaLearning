
using ComputationalHomology
    using Distances
    using DataFrames
    using Random
    using DelimitedFiles

include("GeometricMatrix.jl")

N = 88
dimensions = 5

random_points = generate_random_point_cloud(N, dimensions)
geometric_matrix = generate_geometric_matrix(random_points)
matrix_ordering =  generate_matrix_ordering(geometric_matrix, N)
set_of_graphs, edge_density = generate_set_of_graphs(N, matrix_ordering)
geometric_matrix = -geometric_matrix

# %% markdown
# # At his point, input matrix is assumed to be settled (either random, geometric or correaltion)
# Now Betti curves should be obtained by:
# 0. Creae set of graphs
# 1. Compute simplicial homology groups of the taken (i+1)-clique
# 2. Compute edge density (used later as abscissa)
# 3. Compute Betti number (used later as ordinate)
# %%



# max_distance = findmax(geometric_matrix)
# max_distance = -max_distance[1]

# function do_filtration(m)
points_filtration = zeros(Int, N)
    betti_number = zeros(3, size(matrix_ordering)[2])

m=size(matrix_ordering)[2]
for k=1:Int(floor(m/5))
    points_filtration[matrix_ordering[1,k]] += 1
    points_filtration[matrix_ordering[2,k]] += 1

    mask = map(x -> x>=1, points_filtration)
    subset_of_points = random_points[:,mask]

    max_distance = geometric_matrix[matrix_ordering[1,k], matrix_ordering[2,k]]
# println(subset_of_points)
    cplx, w = vietorisrips(subset_of_points, max_distance, true) # generate Vietoris-Rips (VR) complex
    # println(cplx)
    flt = filtration(cplx, w) # construct filtration complex from VR complex
    ph = persistenthomology(flt) # create persistent homology object with specific computation method


# d = 2
# if size(cplx)[2] <= 2
    for d in 0:1
        betti_number[d+1, k] = group(ph, d)
    end

    if mod(k,10)==0
        println(k)
    end
# else
#     for d in 0:2
#         betti_number[d+1, k] = group(ph, d)
#     end
end
# end
#     println("finished")
# end
using Plots
plot(edge_density, betti_number[2,:])

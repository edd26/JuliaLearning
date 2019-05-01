# %%
using Distances
    using DataFrames
    using Random
    using LightGraphs
    using GraphPlot

include("GeometricMatrix.jl")
# using Graphs

# using Eirene

# %% markdown
# # Generation of geometric matrix
# Geometric matrices were obtained by sampling a set of N i.i.d. points were
# then given by Cij = −||pi − pj||, where the minus sign ensures that they
# monotonically uniformly distributed in the d-dimensional unit cube
# [0, 1]d ⊂ Rd, for d ≤ N. The matrix entries decrease with distance, as
# expected for geometrically organized correlations.

# Each column is a set of coordinates for a point,
#  each row n is set of coordinates of all points in the n-th dimension



random_points = generate_random_point_cloud(12,3)
# ### Computing inverse of distance between points stored in "random_points"
# A sibstitute for correlatioin matrix



geometric_matrix = generate_geometric_matrix(random_points)


# %%
# # Odering Matrix
# Find the minimum value, return indicies, remove it, repeat until all are 0.0, inverse matrix.
# First element in final "matrix ordering" is of points with smallest distance.
# (The indexing is inversed in comparison to the article)



matrix_ordering =  generate_matrix_ordering(geometric_matrix)

# %% markdown
# # At his point, input matrix is assumed to be settled (either random, geometric or correaltion)
# Now Betti curves should be obtained by:
# 0. Creae set of graphs
# 1. Compute simplicial homology groups of the taken (i+1)-clique
# 2. Compute edge density (used later as abscissa)
# 3. Compute Betti number (used later as ordinate)


#= Utilization of ordering matrix -> create zero matrix called filter of size of
 distance matrix. Add 1 to the position, where first point in ordering matrix
 is. Index distance matrix with filter matrix. Compute Betti numbers, edge
 density. Change filter matrix with next value form ordering matrix. Index
 distance matrix and repeat until there is no element left.

 What about other vetrices? Do not take them into account?
    = Do we use k-simplex or all simplex?
=#

# %% markdown
    # ## Create nested graph
    # Each vertex is the column, because columns represent different elements,
    # between which distance was measured

    # Edges are created between every points up to the level k
vetrices = N
    edges = matrix_ordering
    num_of_edges = size(edges)[2]

    set_of_graphs = [a=Graph(vetrices) for a=1:num_of_edges]
    edges_counter = zeros(Int, num_of_edges)
    edge_density =  zeros(num_of_edges)

    k=1
    for k in range(1,stop=num_of_edges)~
        add_edge!(set_of_graphs[k], edges[1,k], edges[2,k]);
        edges_counter[k] = ne(set_of_graphs[k])
        edge_density[k] = edges_counter[k]/binomial(N,2)



        if k<num_of_edges # if is used to eliminate copying at last iteration
            set_of_graphs[k+1] = copy(set_of_graphs[k])
        end
    end

# %%
# Determine which graph shpuld be displayed
n=4
    nodelabel = [r  for r in 1:nv(set_of_graphs[n])]
    println("Number of edges: ")
    println(edges_counter[n])

    println("Edge density: ")
    println(edge_density[n])

    gplot(set_of_graphs[n], layout=circular_layout, nodelabel=nodelabel)

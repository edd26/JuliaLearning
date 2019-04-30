# %%
using Distances
using DataFrames
using Random
using LightGraphs
using GraphPlot
# using Graphs

# using Eirene

# %% markdown
# # Generation of geometric matrix
# Geometric matrices were obtained by sampling a set of N i.i.d. points were then given by Cij = −||pi − pj||, where the minus sign ensures that they monotonically uniformly distributed in the d-dimensional unit cube [0, 1]d ⊂ Rd, for d ≤ N. The matrix entries decrease with distance, as expected for geometrically organized correlations.
#
# collection of points embedded in some Euclidean space ->  negative distance matrix -> geometric order complex



# %% markdown
# ### Unit cube of dimension "dimension" with the size of dimension "dims_size"



# %%
# Number of sample points
N = 88

# Each column is a set of coordinates for a point,
#   each row n is set of coordinates of all points in the n-th dimension
dimensions = 3
number_of_points = 200
unit_cube = rand(Float64, dimensions, number_of_points)

print("Unit cube size: ")
println(size(unit_cube))
# ezplot_pjs(unit_cube)


# %% markdown
# ##### Choosing N points from the cube



# %%
# Make a list of all points, shuffle the list, take first N points
points = 1:number_of_points
random_columns = shuffle(points)
random_points = unit_cube[:,random_columns[1:N]]



# %% markdown
# ### Computing inverse of distance between points stored in "random_points"
# A sibstitute for correlatioin matrix

# %%
geometric_matrix = pairwise(Euclidean(), random_points, dims=2)
geometric_matrix = -geometric_matrix;


# %%
# # Odering Matrix
# %% markdown
# ### Creating matrix ordering "matrix_ordering" of matrix "geometric_matrix"
#
# Find the minimum value, return indicies, remove it, repeat until all are 0.0, inverse matrix.
#
# First element in final "matrix ordering" is of points with smallest distance.
#
# (The indexing is inversed in comparison to the article)

elemnts_above_diagonal = Int((N^2-N)/2)
matrix_ordering = zeros(Int, 2,elemnts_above_diagonal)

A = copy(geometric_matrix)

k=1
for element in 1:elemnts_above_diagonal
#     Find maximal distance
    minimal_value = findmin(A)
#     Get the coordinates (only 2 dimensions, because it is distance matrix)
    matrix_ordering[1,element] = Int(minimal_value[2][1])
    matrix_ordering[2,element] = Int(minimal_value[2][2])
#
# #     Zero minval in A (above and below diagonal) so next minval can be found
    A[matrix_ordering[1,element], matrix_ordering[2,element]] = 0.0
    A[matrix_ordering[2,element], matrix_ordering[1,element]] = 0.0

    # k = k + 1
end

# change from min to max order to the max to min order (? necessary ?)
matrix_ordering = matrix_ordering[:,end:-1:1]


# %% markdown
# # At his point, input matrix is assumed to be settled (either random, geometric or correaltion)
# Now Betti curves should be obtained by:
# 0. Creae set of graphs
# 1. Compute simplicial homology groups of the taken (i+1)-clique
# 2. Compute edge density (used later as abscissa)
# 3. Compute Betti number (used later as ordinate)

# %%
using ComputationalHomology



# %%
X = rand(3,10); # generate dataset
cplx, w = vietorisrips(random_points, 0.4, true) # generate Vietoris-Rips (VR) complex
flt = filtration(cplx, w) # construct filtration complex from VR complex
ph = persistenthomology(flt) # create persistent homology object with specific computation method

# %%

group(ph, 1)



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
# There is as much graphs as there is random indicies=N



# %%
# Each vertex is the column, because columns represent different elements, between which distance was measured
vetrices = N #

# Edges are created between every points up to the level k
edges = matrix_ordering
num_of_edges = size(edges)[2]

# g = SimpleGraph(vetrices);

set_of_graphs = [a=Graph(vetrices) for a=1:num_of_edges]
edges_counter = zeros(Int, num_of_edges)
edge_density =  zeros(num_of_edges)

k=1
for k in range(1,stop=num_of_edges)~
#     set_of_graphs[k]
    add_edge!(set_of_graphs[k], edges[1,k], edges[2,k]);
    edges_counter[k] = ne(set_of_graphs[k])
    edge_density[k] = edges_counter[k]/binomial(N,2)
    if k<num_of_edges
        set_of_graphs[k+1] = copy(set_of_graphs[k])
    end
end



# %%
n=300

nodelabel = [r  for r in 1:nv(set_of_graphs[n])]
println("Number of edges: ")
println(edges_counter[n])

println("Edge density: ")
println(edge_density[n])

gplot(set_of_graphs[n], layout=circular_layout, nodelabel=nodelabel)

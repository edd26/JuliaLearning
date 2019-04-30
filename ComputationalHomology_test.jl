# %%
# %%
using ComputationalHomology



# %%
using Distances
using DataFrames
using Random

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

# Make a list of all points, shuffle the list, take first N points
points = 1:number_of_points
random_columns = shuffle(points)
random_points = unit_cube[:,random_columns[1:N]]


geometric_matrix = pairwise(Euclidean(), random_points, dims=2)
geometric_matrix = geometric_matrix;


# %%
# # Odering Matrix
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

X = rand(3,10); # generate dataset
# some_complex = SimplicialComplex(matrix_ordering)

cplx1 = SimplicialComplex{Simplex{Int}}()
    for s in [[1, 2, 3], [1, 3, 4], [1, 2, 6], [1, 5, 6], [1, 4, 5],
              [2, 3, 5], [2, 4, 5], [2, 4, 6], [3, 4, 6], [3, 5, 6]]
        addsimplices!(cplx, Simplex(s))
    end

cplx, w = vietorisrips(random_points, 0.4, true) # generate Vietoris-Rips (VR) complex
flt = filtration(cplx, w) # construct filtration complex from VR complex
ph = persistenthomology(flt) # create persistent homology object with specific computation method

# %%

group(ph, 1)

# Example 1
using TDA, ComputationalHomology, Plots
    # crate some intervals of various dimensions
    ints = vcat(intervals(0, 2.0=>6.0, 5.0=>10.0, 1.0=>Inf), intervals(1, 9.0=>12.0))
    # plot persistance diagram
    plot(ints)
    # plot barcode
    plot(ints, seriestype=:barcode)

# Example 2
using TDA, ComputationalHomology, Plots
    # generate simplicial complex
    cplx = ComputationalHomology.sphere(5)
    # generate some points on circle
    D = mapslices(p->p./sqrt(sum(p.^2)), randn(30,2), dims=2)
    # plot points
    plot(D[:,1], D[:,2], seriestype = :scatter, markersize = 2)
    # plot nerve
    plot!(cplx, D, linewidth = 2) # or plot(cplx)

ComputationalHomology.

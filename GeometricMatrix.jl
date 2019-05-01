
# module GeometricMatrix
#
# export generate_random_point_cloud,
#     generate_geometric_matrix,
#     generate_matrix_ordering

function generate_random_point_cloud(number_of_points = 12, dimensions=2)
    N = number_of_points
    random_points = rand(Float64, dimensions, N)
    return random_points
end

function generate_geometric_matrix(random_points)
    geometric_matrix = pairwise(Euclidean(), random_points, dims=2)
    return -geometric_matrix
end

function generate_matrix_ordering(geometric_matrix)
    elemnts_above_diagonal = Int((N^2-N)/2)
    matrix_ordering = zeros(Int, 2,elemnts_above_diagonal)

    A = copy(geometric_matrix)

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
    end

    # change from min to max order to the max to min order (? necessary ?)
    matrix_ordering = matrix_ordering[:,end:-1:1]

    return matrix_ordering
end
# 
# end
#
# push!(LOAD_PATH, "home/ed19aaf/Programming/Julia/JuliaLearning")

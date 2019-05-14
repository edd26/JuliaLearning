using Distances
 using DataFrames
 using Random
 using LightGraphs
 using GraphPlot

function generate_random_point_cloud(number_of_points = 12, dimensions=2)
    matrix_size = number_of_points
    random_points = rand(Float64, dimensions, matrix_size)
    return random_points
end

function generate_geometric_matrix(random_points)
    geometric_matrix = pairwise(Euclidean(), random_points, dims=2)
    return -geometric_matrix
end

function generate_shuffled_matrix(geometric_matrix)
    matrix_size = size(geometric_matrix,1)

    indicies_collection = findall(x->x<0, geometric_matrix)
    rand!(indicies_collection, indicies_collection)
    shuffeled_matrix = copy(geometric_matrix)

    # Swap the elements
    n=1
    for k in 1:matrix_size
        for m in k+1:matrix_size
            a = indicies_collection[n][1]
            b = indicies_collection[n][2]
            shuffeled_matrix[k,m] = geometric_matrix[a,b]
            shuffeled_matrix[m,k] = geometric_matrix[b,a]

            shuffeled_matrix[a,b] = geometric_matrix[k,m]
            shuffeled_matrix[b,a] = geometric_matrix[m,k]

            n +=1
        end
    end
    return shuffeled_matrix
end

function generate_random_matrix(matrix_size)
    elemnts_above_diagonal = Int((matrix_size^2-matrix_size)/2)
    random_matrix = zeros(size(geometric_matrix))
    set_of_random_numbers = rand(elemnts_above_diagonal)

    h = 1
    for k in 1:matrix_size
        for m in k+1:matrix_size
            random_matrix[k,m] = set_of_random_numbers[h]
            random_matrix[m,k] = set_of_random_numbers[h]
            global h +=1
        end
    end
end

function generate_matrix_ordering(geometric_matrix, matrix_size)
    elemnts_above_diagonal = Int((matrix_size^2-matrix_size)/2)
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

function generate_set_of_graphs(matrix_size, matrix_ordering)
    vetrices = matrix_size
    edges = matrix_ordering
    num_of_edges = size(edges)[2]

    set_of_graphs = [a=Graph(vetrices) for a=1:num_of_edges]
    edges_counter = zeros(Int, num_of_edges)
    edge_density =  zeros(num_of_edges)

    k=1
    for k in range(1,stop=num_of_edges)~
        add_edge!(set_of_graphs[k], edges[1,k], edges[2,k]);
        edges_counter[k] = ne(set_of_graphs[k])
        edge_density[k] = edges_counter[k]/binomial(matrix_size,2)

        if k<num_of_edges # if is used to eliminate copying at last iteration
            set_of_graphs[k+1] = copy(set_of_graphs[k])
        end
    end
    return set_of_graphs, edge_density
end

function plot_betti_numbers(betti_numbers, title="Geometric  matrix")
    x_values = range(0,stop=0.6,length=size(betti_numbers)[1])

    plot(x_values, betti_numbers[:,1], label="beta_0", title=title) #, ylims = (0,maxy)
    plot!(x_values, betti_numbers[:,2], label="beta_1")
    plot!(x_values, betti_numbers[:,3], label="beta_2")
end

function save_matrix_to_file(matrix, filename)
    open(filename, "w") do io
        writedlm(io,  matrix, ',')
    end
end

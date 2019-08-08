using Random
using Plots
using Distributions

plot_figures = false

# rng = MersenneTwister(1234);
rng = MersenneTwister();

cloud_size = 100
cloud_dim = 2
random_matrix = zeros(Float64, cloud_dim, cloud_size)
rand!(rng, random_matrix)

function set_range(my_matrix, min_val, max_val; val_type = Int)
    values_range = max_val - min_val
    new_matrix = abs.(my_matrix)

    new_matrix .*= values_range
    new_matrix .+= min_val

    if val_type == Int
        new_matrix = (trunc.(Int, new_matrix))
    end

    return new_matrix
end






















my_new_matrx = set_range(random_matrix, -1, 1, val_type = Float64)

function restric_to_circle(my_matrix; radius = 1)
    new_matrix = my_matrix
    # Add handing input matrix from range different from [-1,1]

    dims, cloud_size = size(new_matrix)
    radius_sq = radius^2

    for point = 1:cloud_size
        if sum(new_matrix[:,point].^2) > radius_sq
            new_matrix[2, point] = rand(-1:2:1) * sqrt(radius_sq -
                                    (rand(Uniform(-abs(new_matrix[1, point]),
                                                    abs(new_matrix[1, point]))))^2)
            # cloud[1, point] = rand(Uniform(-random_radius[point],random_radius[point]))
            # new_matrix[:,point] ./= 2
        end
    end
    return new_matrix
end

random_circle = restric_to_circle(my_new_matrx)
plot(random_circle[1,:], random_circle[2,:],seriestype=:scatter,title="circle matrx")

if plot_figures
    plot(my_new_matrx[1,:], my_new_matrx[2,:],seriestype=:scatter,title="my_new_matrx")

end

function generate_circle_cloud(cloud_size =100 ;min_vals=(x=-1, y=-1), max_vals=(x=1, y=1),
                                                         cloud_dim=2)

    diameter = max_vals.y - min_vals.x
    radius = trunc(Int, (diameter) / 2)
    cloud = zeros(Float64, cloud_dim, cloud_size)

    random_radius = rand(Float64, 1, cloud_size)

    for point = 1:cloud_size
        cloud[1, point] = rand(Uniform(-random_radius[point],random_radius[point]))
        cloud[2, point] = sqrt.(random_radius[point].^2 .- cloud[1, point].^2) * rand(-1:2:1)
    end

    # rng_values = zeros(Float64, 2, cloud_size)
    #
    # rand!(rng, rng_values)
    # rng_values[1,:] .*= diameter
    # rng_values[1,:] .+= min_vals.x
    #
    # cloud[1,:] = rng_values[1,:];
    #
    # # y = sqrt( r^2 - x^2)
    # cloud[2,:] = sqrt.(rng_values[2,:].^2 .- rng_values[1,:].^2)

    # Scaling and shifting
    #
    # ...

    return cloud
end

circle_cloud = generate_circle_cloud(1000);

plot(circle_cloud[1,:], circle_cloud[2,:],seriestype=:scatter,title="circle matrx")

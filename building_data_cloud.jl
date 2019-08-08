using Random
using Plots
using Distributions

plot_figures = false

# rng = MersenneTwister(1234);

cloud_size = 1000
cloud_dim = 2
random_matrix = zeros(Float64, cloud_dim, cloud_size)
rand!(random_matrix)

plot(random_matrix[1,:], random_matrix[2,:],seriestype=:scatter,title="random_matrix")


my_matrix = random_matrix
my_center = (x=0, y=0)
my_radius = 2
my_limits = (xlim = (my_center.x-my_radius, my_center.x+my_radius),
                ylim = (my_center.y-my_radius, my_center.y+my_radius))

    #=
    This functin is not generating uniform distribution, as the elements outside the
    radius are mapped to the values near the border of the radius, as they are
    distributed for a smaller field.

    In other words, the distribution from outside the radius are mapped to the
    border values of the circle.
    =#
function restric_to_circle(my_matrix; center=(x=0, y=0), radius = 1)
    cloud = copy(my_matrix)
    # Add handing input matrix from range different from [-1,1]

    dims, cloud_size = size(cloud)
    radius_sq = radius^2

    for point = 1:cloud_size
        if sum(cloud[:,point].^2) > 1
            val = abs(cloud[1, point])
            range_val = Uniform(val, 1)
            new_val = rand(range_val)
            y = sqrt(new_val - val^2)
            cloud[2, point] = y
        end
    end
    cloud .*= rand!(zeros(dims, cloud_size), -1:2:1)
    cloud .*= radius
    cloud[1,:] .+= center.x
    cloud[2,:] .+= center.y
    return cloud
end


#= Remove values which are in the given circle
=#
function restric_from_area(my_matrix; center=(x=0, y=0), radius = 1.)
    cloud = copy(my_matrix)
    # Add handing input matrix from range different from [-1,1]

    dims, cloud_size = size(cloud)
    radius_sq = radius^2

    for pt = 1:cloud_size
        if (cloud[1,pt] > center.x-radius && cloud[1,pt] < center.x+radius) &&
            (cloud[2,pt] > center.y-radius && cloud[2,pt] < center.y+radius)
            cloud[:,pt] = zeros(2,1)
        end
    end


    all_non_zeros = findall(x -> x==0, cloud)[1:2:end]
    indices = zeros(Int, 1, size(all_non_zeros)[1])

    for k=1:size(all_non_zeros)[1]
        indices[k] = Int(all_non_zeros[k][2])
    end

    cloud = cloud[:,indices[1,:]]
    return cloud
end



random_circle = restric_to_circle(random_matrix, center = my_center, radius=my_radius)
plot(random_circle[1,:], random_circle[2,:],seriestype=:scatter,
    title="circle matrx",xlims = my_limits.xlim, ylims = my_limits.ylim)

random_circle_mod = restric_from_area(random_matrix, center = my_center, radius=0.5)
plot(random_circle_mod[1,:], random_circle_mod[2,:],seriestype=:scatter,
    title="circle matrx",xlims = my_limits.xlim, ylims = my_limits.ylim)
















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









# This does not generate uniform distribution as the values arebounded to one another
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

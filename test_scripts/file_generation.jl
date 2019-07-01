using Distances
 using Eirene
 using DelimitedFiles
 include("../MatrixToolbox.jl")

 using Random

 Random.seed!(1234)

save = true

dimensions = 20
 N = 80
 random_points = generate_random_point_cloud(N, dimensions)
 geometric_matrix = generate_geometric_matrix(random_points)
 shuffeled_matrix = generate_shuffled_matrix(geometric_matrix)
 random_matrix = generate_random_matrix(N)

filepath = eirenefilepath("noisycircle")
circle_cloud = readdlm( filepath,  ',', Float64, '\n')

circle_matrix = generate_geometric_matrix(circle_cloud)

filepath = eirenefilepath("noisytorus")
torus_cloud = readdlm( filepath,  ',', Float64, '\n')

torus_matrix = generate_geometric_matrix(torus_cloud)

# Save Matricies to csv files
if save
    writedlm( "distances.csv",  geometric_matrix, ',')
    writedlm( "circle.csv",  circle_matrix, ',')
    writedlm( "torus.csv",  torus_matrix, ',')
end

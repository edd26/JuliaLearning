using MATLAB
 using DelimitedFiles
 using Plots


geometric_matrix = readdlm( "geometric_matrix.csv",  ',', Float64, '\n')
 shuffeled_matrix = readdlm( "shuffeled_matrix.csv",  ',', Float64, '\n')
 random_matrix = readdlm( "random_matrix.csv",  ',', Float64, '\n')


mat"ending = 60"
mat"$geom_betti_numbers = compute_clique_topology($geometric_matrix(1:ending, 1:ending), 'Algorithm', 'split');"
mat"$rand_betti_numbers = compute_clique_topology($random_matrix(1:ending, 1:ending), 'Algorithm', 'split');"
mat"$shuf_betti_numbers = compute_clique_topology($shuffeled_matrix(1:ending, 1:ending), 'Algorithm', 'split');"


function plot_betti_numbers(betti_numbers, title="Geometric  matrix")
    x_values = range(0,stop=0.6,length=size(betti_numbers)[1])

    plot(x_values, betti_numbers[:,1], label="beta_0", title=title) #, ylims = (0,maxy)
    plot!(x_values, betti_numbers[:,2], label="beta_1")
    plot!(x_values, betti_numbers[:,3], label="beta_2")
end

writedlm("geometric_betties.csv",  geom_betti_numbers, ',')
writedlm("random_betties.csv",  rand_betti_numbers, ',')
writedlm("shuffled_betties.csv",  shuf_betti_numbers, ',')


plot_betti_numbers(geom_betti_numbers, "Geometric  matrix")
plot_betti_numbers(rand_betti_numbers, "Random  matrix")
plot_betti_numbers(shuf_betti_numbers, "Shuffled  matrix")

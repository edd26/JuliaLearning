using Plots
 using MATLAB
 using Eirene
 include("../VideoProcessing.jl")
 include("../MatrixToolbox.jl")
 include("../Settings.jl")
 include("../clique_top_Julia/CliqueTop.jl")


## Test code for Eirene

## generate random matrix for comparison
random_matrix = generate_random_matrix(40)

ran_betti_num, edgeDensities, persistenceIntervals, unboundedIntervals =
         compute_clique_topology(random_matrix)
R = eirene(random_matrix,maxdim=3,model="vr")

p1 = plot_betti_numbers(ran_betti_num, edgeDensities, "Random  matrix clique top");
# %%
betti_0 = betticurve(R, dim=0)
betti_1 = betticurve(R, dim=1)
betti_2 = betticurve(R, dim=2)
betti_3 = betticurve(R, dim=3)

p2 = plot(betti_0[:,1], betti_0[:,1], label="beta_0", title="Random matrix Eirene"); #, ylims = (0,maxy)
plot!(betti_1[:,1], betti_1[:,2], label="beta_1");
plot!(betti_2[:,1], betti_2[:,2], label="beta_2");
plot!(betti_3[:,1], betti_3[:,2], label="beta_3");

plot_ref = plot(p1, p2, layout = (2,1))

cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
savefig(plot_ref, "results/comparison_random_matrix.png")







## Load geometric matrix for comparison
geometric_matrix = readdlm( "geometric_matrix.csv", ',', Float64, '\n')
size_limiter = 70
geometric_matrix = geometric_matrix[1:size_limiter, 1:size_limiter]
geo_betti_num, edgeDensities, persistenceIntervals, unboundedIntervals =
         compute_clique_topology(geometric_matrix)
R = eirene(-geometric_matrix,maxdim=3,model="vr")

p1 = plot_betti_numbers(geo_betti_num, edgeDensities, "Geometric matrix clique top, size $size_limiter");
# %%
betti_0 = betticurve(R, dim=0)
betti_1 = betticurve(R, dim=1)
betti_2 = betticurve(R, dim=2)
# betti_3 = betticurve(R, dim=3)

p2 = plot(betti_0[:,1], betti_0[:,1], label="beta_0", title="Geometric matrix Eirene, size $size_limiter"); #, ylims = (0,maxy)
plot!(betti_1[:,1], betti_1[:,2], label="beta_1");
plot!(betti_2[:,1], betti_2[:,2], label="beta_2");
# plot!(betti_3[:,1], betti_3[:,2], label="beta_3");

plot_ref = plot(p1, p2, layout = (2,1))

cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
savefig(plot_ref, "results/comparison_geometric_matrix.png")

using Plots
 using MATLAB
 using Eirene
 using Random
 using Distances
 using DelimitedFiles
 mat"addpath('clique-top')"

x = rand(3,50)
    C = eirene(x, model = "pc")
    plotbarcode_pjs(C,dim=1)
    plotpersistencediagram_pjs(C,dim=1)
    plotclassrep_pjs(C,dim=1,class=1)
    plotbetticurve_pjs(C, dim=1)



filepath = eirenefilepath("noisytorus")
pointcloud = readdlm(filepath, ',', Float64, '\n')
set_size = size(pointcloud)[2]
lim = 500;
reduced = pointcloud[:, Int.(floor.(range(1, stop=set_size, step = set_size/lim)))]

ezplot_pjs(reduced)
pointcloud_distances = pairwise(Euclidean(), reduced, dims=2)
matlab_file = "../../Python/distances.csv"
open(matlab_file, "w") do io
    # for row in 1:lim
    #     for column in 1:100
            writedlm(io, pointcloud_distances, ";")

end

C = eirene(reduced, model = "pc", maxdim=2)
plotbetticurve_pjs(C, dim=2)
plotpersistencediagram_pjs(C, dim=1)

mat"[A, B, C, D] = compute_clique_topology($pointcloud_distances, 'Algorithm', 'split');"
mat"""$cloud_betti_num = A;
 $edgeDensities_c = B;
 $persistenceIntervals = C;
 $unboundedIntervals = D;"""


# clique-top plotting
title = "Cloud  matrix, clique-top"
p_rand_ct = plot(edgeDensities_c[:], cloud_betti_num[:,1], label="beta_0",
                                             title=title, legend=:topleft);
plot!(edgeDensities_c[:], cloud_betti_num[:,2], label="beta_1");
plot!(edgeDensities_c[:], cloud_betti_num[:,3], label="beta_2")

using Eirene
using DelimitedFiles

geometric_matrix = readdlm( "geometric_matrix.csv",  ',', Float64, '\n')
ending = 20

R = eirene(geometric_matrix,maxdim=3,model="vr")


betti_0 = betticurve(R, dim=0)
betti_1 = betticurve(R, dim=1)
betti_2 = betticurve(R, dim=2)
betti_3 = betticurve(R, dim=3)

p1 = plot(betti_0[:,1], betti_0[:,2], label="beta_0", title="Geometric matrix Eirene"); #, ylims = (0,maxy)
plot!(betti_1[:,1], betti_1[:,2], label="beta_1");
plot!(betti_2[:,1], betti_2[:,2], label="beta_2");
plot!(betti_3[:,1], betti_3[:,2], label="beta_3");

plot_ref = plot(p1)

cd("/home/ed19aaf/Programming/Julia/JuliaLearning")
savefig(plot_ref, "results/eirene_geometric_matrix.png")

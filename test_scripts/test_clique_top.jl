# using MATLAB
using DelimitedFiles
 using Plots
 using Debugger


geometric_matrix = readdlm( "geometric_matrix.csv",  ',', Float64, '\n')
ending = 20


include("clique_top/clique_top.jl")
geom_betti_numbers = compute_clique_topology(geometric_matrix[1:ending, 1:ending], algorithm = "split", reportProgress=true);

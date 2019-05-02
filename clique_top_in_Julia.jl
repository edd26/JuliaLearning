using MATLAB
using DelimitedFiles


geometric_matrix = readdlm( "geometric_matrix.csv",  ',', Float64, '\n')
 shuffeled_matrix = readdlm( "shuffeled_matrix.csv",  ',', Float64, '\n')
 random_matrix = readdlm( "random_matrix.csv",  ',', Float64, '\n')


mat"ending = 50"
mat"compute_clique_topology($geometric_matrix(1:ending, 1:ending), 'Algorithm', 'split');"

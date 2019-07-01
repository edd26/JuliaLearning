# %%
using Distances
 using DataFrames
 # using Random
 using LightGraphs
 using GraphPlot
 using Plots
 using Eirene
 using DelimitedFiles
 include("../MatrixToolbox.jl")

 using Random

 Random.seed!(1234)

save = false

# collection of points embedded in some Euclidean space ->  negative distance matrix -> geometric order complex
# Each column is a point, each row n is coordinate in the n-th dimension
dimensions = 20
 N = 5
 random_points = generate_random_point_cloud(N, dimensions)
 geometric_matrix = generate_geometric_matrix(random_points)
 shuffeled_matrix = generate_shuffled_matrix(geometric_matrix)
 random_matrix = generate_random_matrix(N)

# Save Matricies to csv files
if save
    writedlm( "geometric_matrix.csv",  geometric_matrix, ',')
    writedlm( "shuffeled_matrix.csv",  shuffeled_matrix, ',')
    writedlm( "random_matrix.csv",  random_matrix, ',')
end


## Compute topoplogies of matricies
my_maxdim = 3
ending = 40

geom_eirene = eirene(geometric_matrix, model="vr", maxdim=my_maxdim)
 shuffled_eirene = eirene(shuffeled_matrix, model="vr", maxdim=my_maxdim)
 random_eirene= eirene(random_matrix[1:ending, 1:ending], model="vr", maxdim=my_maxdim)

# Get the betti curves f
dimen = 1

# Geomteric
# plotbarcode_pjs(geom_eirene)
geom_betti1 = betticurve(geom_eirene, dim=1)
 geom_betti = zeros(size(geom_betti1)[1], 3+1)
 geom_betti[:,1] = geom_betti1[:,1]
 for k in 1:3
     geom_betti[:,k+1] = betticurve(geom_eirene, dim=k)[:,2]
 end

# Shuffle
shuffled_betti1 = betticurve(shuffled_eirene, dim=1)
 shuffled_betti = zeros(size(shuffled_betti1)[1], 3+1)
 shuffled_betti[:,1] = shuffled_betti1[:,1]
 for k in 1:3
     shuffled_betti[:,k+1] = betticurve(shuffled_eirene, dim=k)[:,2]
 end

# Random
random_betti1 = betticurve(random_eirene, dim=1)
 random_betti = zeros(size(random_betti1)[1], 3+1)
 random_betti[:,1] = random_betti1[:,1]
 for k in 1:3
     random_betti[:,k+1] = betticurve(random_eirene, dim=k)[:,2]
 end
# %%
matrix = random_betti
 maxy = findmax(matrix[:,2])[2]
 plot(matrix[:,1], matrix[:,2], label="Random matrix, dim=1", ylims = (0,maxy))
 plot!(matrix[:,1], matrix[:,3], label="Random matrix, dim=2")
 plot!(matrix[:,1], matrix[:,4], label="Random matrix, dim=3")
 # %%
matrix = shuffled_betti
 plot(matrix[:,1], matrix[:,2], label="Shuffled matrix, dim=1", ylims = (0,maxy))
 plot!(matrix[:,1], matrix[:,3], label="Shuffled matrix, dim=2")
 plot!(matrix[:,1], matrix[:,4], label="Shuffled matrix, dim=3")
 # %%
matrix = geom_betti
 plot(matrix[:,1], matrix[:,2], label="Geometric matrix, dim=1", ylims = (0,maxy))
 plot!(matrix[:,1], matrix[:,3], label="Geometric matrix, dim=2")
 plot!(matrix[:,1], matrix[:,4], label="Geometric matrix, dim=3")

betticurve(shuffled_eirene, dim=1)

# %%
dimen = 2

plot_shuffle = true
plot_geom = !plot_shuffle

plot_betti = false
plot_persistance = false
plot_bar = true

if plot_geom
    if plot_betti
        plotbetticurve_pjs(geom_eirene, dim=dimen)
    elseif plot_persistance
        plotpersistencediagram_pjs(geom_eirene,dim=dimen)
    elseif plot_bar
        plotbarcode_pjs(geom_eirene,dim=0:dimen)
    end
elseif plot_shuffle
        if plot_betti
        plotbetticurve_pjs(shuffled_eirene, dim=dimen)
    elseif plot_persistance
        plotpersistencediagram_pjs(shuffled_eirene,dim=dimen)
    elseif plot_bar
        plotbarcode_pjs(shuffled_eirene,dim=0:dimen)
    end
end



## Creating matrix ordering "matrix_ordering" of matrix "geometric_matrix"
matrix_ordering = generate_matrix_ordering(geometric_matrix)

## Create nested graph
# There is as much graphs as there is random indicies=N
# Each vertex is the column, because columns represent different elements, between which distance was measured
vetrices = N

# Edges are created between every points up to the level k
edges = matrix_ordering
num_of_edges = size(edges)[2]

# g = SimpleGraph(vetrices);

set_of_graphs = [a=Graph(vetrices) for a=1:num_of_edges]
edges_counter = zeros(Int, num_of_edges)
edge_density =  zeros(num_of_edges)

k=1
for k in range(1,stop=num_of_edges)~
#     set_of_graphs[k]
    add_edge!(set_of_graphs[k], edges[1,k], edges[2,k]);
    edges_counter[k] = ne(set_of_graphs[k])
    edge_density[k] = edges_counter[k]/binomial(N,2)
    if k<num_of_edges
        set_of_graphs[k+1] = copy(set_of_graphs[k])
    end
end
# %%
n=300

nodelabel = [r  for r in 1:nv(set_of_graphs[n])]
println("Number of edges: ")
println(edges_counter[n])

println("Edge density: ")
println(edge_density[n])

gplot(set_of_graphs[n], layout=circular_layout, nodelabel=nodelabel)
# %% markdown
# # Compute Betti curve for matrix_ordering
# %%
using Eirene
using SparseArrays
# %% markdown
# ## "point cloud" mode
# %%
ezplot_pjs(matrix_ordering[:,1:500])
# %%
C = eirene(matrix_ordering[:,1:500],maxdim=2, maxrad=20,model="pc")
# %%
plotpersistencediagram_pjs(C,dim=1)
# %%
plotbetticurve_pjs(C, dim=1)
# %%
#1 D is created from matrix ordering
D = zeros(Int,N,N)

for k in range(1,stop=n) # n from the jupytrt cell in which graph is created
# println(matrix_ordering[:,k])
    D[matrix_ordering[1,k], matrix_ordering[2,k]] += 1
    D[matrix_ordering[2,k], matrix_ordering[1,k]] += 1
end

# %% markdown
# ### "complex mdoe"
# Suppose that G is the last in a nested sequence of graphs G1, G2, G3.
#
# G1 is just the vertex v1 and G2 is the (unconnected) pair of vertices v1, v2.
#
# 1. let D be the N x N zero/one matrix with D[i,j] = 1 iff i is a face of cell j
# 2. S  = sparse(D)
# 3. rv = S.rowval
# 4. cp = S.colptr
#
# 5. dv[i] is the dimension of cell i
# 6. ev[k] is the total number of cells with dimension k-1
# 7. dp[k] is 1 plus the number of cells of dimension strictly less than k-1
# 8. If in addition we have a nested sequence of complexes E_0 ≤ ... ≤ E_n = E, then let fv be the vector such that
#
#     fv[i] is the birthtime of cell i
#
# #### model="complex" is useless because not a single example works in this mode
# - at line 2716 there are errors in indexing
# %%
#1 D is created from matrix ordering
D = zeros(Int,N,N)

for k in range(1,stop=n) # n from the jupytrt cell in which graph is created
# println(matrix_ordering[:,k])
    D[matrix_ordering[1,k], matrix_ordering[2,k]] = 1
    D[matrix_ordering[2,k], matrix_ordering[1,k]] = 1
end

for row in eachrow(D)
    println(row)
end
# %%
# NOT WORKING MODE

# fv = [0.1*a for a in 1:n]

# S = sparse(D)
# rv = S.rowval
# cp = S.colptr

# dv = [0,1]
# ev = [1,1]

# # C = eirene(model="complex", rv=rv,cp=cp,fv=fv, ev=ev, maxdim=1)
# C = eirene(model="complex", rv=rv,cp=cp,fv=fv, dv=dv, maxdim=1)
# # keyword input <rv> is a vector, and none of <dv>, <dp>, and <ev> is nonempty
# %%
# 2, 3, 4
S = sparse(D)
rv = S.rowval
cp = S.colptr

rv = [1,2]
cp = [1,1,3]
# %%
# 5-> all the cells are in 2 dimension the number of cells does not change
dv = [0,0,1]#ones(Int, N) .* 2

# 6 -> the number of cells does not change
ev = [2,1,0]

# 7
dp = [1,2,4,4]

# 8  but might be set to either edge density or just sequence 1:number_of_edges
fv = [0.1*a for a in a:n]  #[a for a in 0.01:0.01:0.2]

# C = eirene(rv=rv,cp=cp, fv=fv, dp=dp, maxdim=1)
C = eirene(rv=rv,cp=cp,dv=dv,fv=fv)

#  C = eirene("/home/ed19aaf/Programming/Julia/Eirene/ez.csv",model="complex",entryformat="sp")
# C =eirene("/home/ed19aaf/Programming/Julia/Eirene/ez.csv",model="complex",  entryformat=  "dp")
# %%
plotbetticurve_pjs(C, dim=1)
# %%

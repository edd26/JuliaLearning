using Plots
 using MATLAB
 include("VideoManage.jl")
 include("GeometricMatrix.jl")
 using Eirene

VIDEO = (diag_1=1,
            diag_2=2,
            diag_g1=3,
            diag_g2=4,
            diag_gb=5,
            diag_dbl=6,
            horiz=7)

choice = VIDEO.horiz
 tau_max = 5
 points_per_dim = 8;
 video_path = pwd()* "/videos/"





# for choice = 1:length(VIDEO)

if choice == VIDEO.diag_1
    video_name = "diag_strip_30sec_1.mov"
 elseif choice == VIDEO.diag_2
    video_name = "diag_strip_30sec_2.mov"
 elseif choice == VIDEO.diag_g1
    video_name = "diag_strip_30sec_gray_1.mov"
 elseif choice == VIDEO.diag_g2
    video_name = "diag_strip_30sec_gray_2.mov"
 elseif choice == VIDEO.diag_gb
    video_name = "diag_strip_30sec_gray_both.mov"
 elseif choice == VIDEO.diag_dbl
    video_name = "diag_strip_30sec_single_dbl_gaps.mov"
 elseif choice == VIDEO.horiz
    video_name = "horiz_strip_30sec.mov"
 end

#
video_array = get_video_array_from_file(video_path*video_name)
video_dimensions = get_video_dimension(video_array)
indicies_set = get_video_mask(points_per_dim, video_dimensions)
extracted_pixels = extract_pixels_from_video(video_array,
                                                indicies_set, video_dimensions)
vectorized_video = vectorize_video(extracted_pixels)
C_ij = get_pairwise_correlation_matrix(vectorized_video, tau_max)
# log_C_ij = map(log10, map(abs,C_ij))

heatmap(C_ij,  color=:lightrainbow, title="Cij, $choice, number of points: $points_per_dim")
# end

# set the diagonal to zero
for diag_elem in 1:size(C_ij,1)
   C_ij[diag_elem,diag_elem] = 0
end

# Application of clique-top library to the correlation matrix
ending = 60
c_ij_betti_numbers = 0
random_betti_numbers = 0

# Generate random matrix
num_of_points = size(C_ij,1)
elemnts_above_diagonal = Int64(num_of_points*(num_of_points-2))
random_matrix = zeros(size(C_ij))
set_of_random_numbers = rand(elemnts_above_diagonal)
h = 1
for k in 1:num_of_points
    for m in k+1:num_of_points
        random_matrix[k,m] = set_of_random_numbers[h]
        random_matrix[m,k] = set_of_random_numbers[h]
       global  h +=1
    end
end


## Copute persistance homology with the MATLAB clique-top library 
println("Computing betti numbers for pairwise correlation matrix.")
mat"addpath('clique-top'); $c_ij_betti_numbers = compute_clique_topology($C_ij(1:$ending, 1:$ending), 'MaxEdgeDensity', 0.6)"


println("Computing betti numbers for pairwise correlation matrix.")
mat"addpath('clique-top'); $random_betti_numbers = compute_clique_topology($random_matrix(1:$ending, 1:$ending), 'MaxEdgeDensity', 0.7)"

plot_betti_numbers(random_betti_numbers, "Pairwise correlation  matrix, matrix size $ending")

plot_betti_numbers(c_ij_betti_numbers, "Pairwise correlation  matrix, matrix size $ending")

# TODO Compare the Eirene with clique top results
# TODO Test the influence of parameters at the betti curves

## Copute persistance homology with the Eirene library

C = eirene(random_matrix,maxdim=3,model="vr")

plotpersistencediagram_pjs(C,dim=1)
# %%
betti_0 = betticurve(C, dim=0)
betti_1 = betticurve(C, dim=1)
betti_2 = betticurve(C, dim=2)
betti_3 = betticurve(C, dim=3)

plot(betti_0[:,1], betti_0[:,1], label="beta_0", title="Random matrix Eirene") #, ylims = (0,maxy)
plot!(betti_1[:,1], betti_1[:,2], label="beta_1")
plot!(betti_2[:,1], betti_2[:,2], label="beta_2")
plot!(betti_3[:,1], betti_3[:,2], label="beta_3")

C = eirene(random_matrix,maxdim=3,model="vr")

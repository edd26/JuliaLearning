##"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# """"""""""""""""""""""""""""Creation of new images"""""""""""""""""""""""""""

include("GifGenerator.jl")

path = "/home/ed19aaf/Programming/Julia/JuliaLearning/gif/"
gif_name = "sth2.gif"
gif_dims = (width = 600, height = 400, max_len = 360)

generate_gif(dotted_plane, path*gif_name, gif_dims)

img = load_gif_to_array

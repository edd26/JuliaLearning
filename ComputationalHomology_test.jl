# %%
# %%
using ComputationalHomology



# %%
X = rand(3,10); # generate dataset
cplx, w = vietorisrips(random_points, 0.4, true) # generate Vietoris-Rips (VR) complex
flt = filtration(cplx, w) # construct filtration complex from VR complex
ph = persistenthomology(flt) # create persistent homology object with specific computation method

# %%

group(ph, 1)

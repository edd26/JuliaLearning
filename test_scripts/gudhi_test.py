import gudhi
rips_complex = gudhi.RipsComplex(points=[[1, 1], [7, 0], [4, 6], [9, 6], [0, 14], [2, 19], [9, 17]],
    max_edge_length=12.0)

simplex_tree = rips_complex.create_simplex_tree(max_dimension=1)
result_str = 'Rips complex is of dimension ' + repr(simplex_tree.dimension()) + ' - ' + \
    repr(simplex_tree.num_simplices()) + ' simplices - ' + \
    repr(simplex_tree.num_vertices()) + ' vertices.'
print(result_str)
fmt = '%s -> %.2f'
for filtered_value in simplex_tree.get_filtration():
    print(fmt % tuple(filtered_value))


# *********************************************************************************************************************
# Distance matrix example

# import gudhi
rips_complex = gudhi.RipsComplex(distance_matrix=[[],
                                                  [6.0827625303],
                                                  [5.8309518948, 6.7082039325],
                                                  [9.4339811321, 6.3245553203, 5],
                                                  [13.0384048104, 15.6524758425, 8.94427191, 12.0415945788],
                                                  [18.0277563773, 19.6468827044, 13.152946438, 14.7648230602, 5.3851648071],
                                                  [17.88854382, 17.1172427686, 12.0830459736, 11, 9.4868329805, 7.2801098893]],
                                 max_edge_length=12.0)

simplex_tree = rips_complex.create_simplex_tree(max_dimension=1)
result_str = 'Rips complex is of dimension ' + repr(simplex_tree.dimension()) + ' - ' + \
    repr(simplex_tree.num_simplices()) + ' simplices - ' + \
    repr(simplex_tree.num_vertices()) + ' vertices.'
print(result_str)
fmt = '%s -> %.2f'
for filtered_value in simplex_tree.get_filtration():
    print(fmt % tuple(filtered_value))



# *********************************************************************************************************************
# Distance matrix from a file
import gudhi
import csv
import copy

matrix = [[],
          [6.0827625303],
          [5.8309518948, 6.7082039325],
          [9.4339811321, 6.3245553203, 5],
          [13.0384048104, 15.6524758425, 8.94427191, 12.0415945788],
          [18.0277563773, 19.6468827044, 13.152946438, 14.7648230602, 5.3851648071],
          [17.88854382, 17.1172427686, 12.0830459736, 11, 9.4868329805, 7.2801098893]]

print("Type of matrix: {}".format(type(matrix)))

print("Type of matrix element: {}".format(type(matrix[1])))

print("Matrix element value: {}".format((matrix[0])))

# ---
# Load geometric matrix containing distances and remove diagonal and the values
# above it.
# Removing values is notnecessary, as the Rips complex creator supports full
# distance matrix.

with open('distances.csv', 'r') as f:
    reader = csv.reader(f)
    your_list = list(reader)

distances = copy.deepcopy(your_list)
counter = 0
size = len(your_list)

for element in your_list:
    # print(type(element))
    for k in range(size-1, counter-1, -1):
        element.pop(k)
        # print("After {}: {}".format(k, element))

    your_list[counter] = list(map(float, element))
    counter +=1

counter = 0
for element in distances:
    distances[counter] = list(map(float, element))
    counter +=1

# ---
rips_complex = gudhi.RipsComplex(distance_matrix=distances)
rips_complex2 = gudhi.RipsComplex(distance_matrix=your_list,
                                 max_edge_length=20.0)

simplex_tree = rips_complex.create_simplex_tree(max_dimension=3)
simplex_tree2 = rips_complex2.create_simplex_tree(max_dimension=3)


simplex_tree.persistence(min_persistence=-1)
simplex_tree.betti_numbers()

simplex_tree2.persistence()
simplex_tree2.betti_numbers()





result_str = 'Rips complex is of dimension ' + repr(simplex_tree.dimension()) + ' - ' + \
    repr(simplex_tree.num_simplices()) + ' simplices - ' + \
    repr(simplex_tree.num_vertices()) + ' vertices.'
print(result_str)
fmt = '%s -> %.2f'
for filtered_value in simplex_tree.get_filtration():
    print(fmt % tuple(filtered_value))


# Maybe it would be worth to try implement ordering complex in this library

# From here, we can use simplex tree to obtain betti numbers of the complex

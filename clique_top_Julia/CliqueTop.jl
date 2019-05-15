using Combinatorics
using DelimitedFiles

"""----------------------------------------------------------------
 RESTRICT CLIQUES TO SIZE
 written by Chad Giusti, 6/2014

 Given a cell array whose elements are positive integer arrays
 listing vertices in the maximal cliques in a graph, return a
 cell array of cliques appearing in the graph of size no larger
 than maxSize. The list may contain repetitions.

 INPUTS:
	maximalCliques: cell array of positive integer arrays listing
       vertices in maximal cliques of a graph
   maxSize: maximum clique size of interest

 OUTPUTS:
   restrictedCliques: maximal cliques in the graph of size no
       more than maxSize

 ----------------------------------------------------------------
"""
function restrict_max_cliques_to_size(maximalCliques, maxSize,
                                        firstVertex,secondVertex)
# ## Testing code:
# maximalCliques = brokenCliqueSets
# maxSize = maxCliqueSize
# firstVertex = firstVertex
# secondVertex = secondVertex
# ## end testing.

    numSmallCliques = 0;
    for j=1:length(maximalCliques)
        if (length(maximalCliques[j]) < maxSize)
            numSmallCliques = numSmallCliques + 1;
        else
            numSmallCliques = numSmallCliques +
                binomial(length(maximalCliques[j])-2, maxSize-2)
        end
    end

    restrictedCliques = Dict()
    thisSmallClique = 1;

    for j=1:length(maximalCliques)
        if length(maximalCliques[j]) < maxSize
            restrictedCliques[thisSmallClique] = maximalCliques[j]
            thisSmallClique = thisSmallClique + 1;
        else
            vertices = maximalCliques[j];
            subVertices = vertices[findall(x-> (x!= firstVertex) &&
                                                (x!= secondVertex), vertices)]
                # all new cliques will contain the edge removed at this
                # filtration level
            theseSmallCliques = collect(combinations(subVertices, maxSize-2))

            for k=1:size(theseSmallCliques,1)
                restrictedCliques[thisSmallClique] = [theseSmallCliques[k,:][1]; firstVertex;  secondVertex];
                thisSmallClique = thisSmallClique + 1;
            end
        end
    end

    return restrictedCliques
end

"""----------------------------------------------------------------
 PRINT CLIQUE LIST TO PERSEUS FILE
 written by Chad Giusti, 6/2014
%
 Output a cell array of cliques in a particular filtration level
 to the file given by fid in the Perseus non-manifold simplicial complex
 format: each line corresponds to a single clique, and is given by the
 size of the clique, then the vertices, then the filtration level
%
 INPUT:
   cliques: cell array whose elements are positive integer vectors with
       entries giving the vertices of cliques in a graph
   fid: file into which to print the cliques
   filtration: filtration number with which to tag these cliques
%
 ----------------------------------------------------------------
"""
function print_clique_list_to_perseus_file(cliques, fileName, filtration )
# # ## Testing
#     cliques = brokenCliqueSets
#     fid = cliqueFid
# #     ## end testing
    fid = open(fileName, "a")
    for j=1:length(cliques)
        clique_size = size(cliques[j],1)-1
        line = string(clique_size, " ")

        for element in cliques[j]
            line = line*string(element, " ")
        end
        line = line*string(filtration, "\n")
        write(fid,line)
    end
    close(fid)
end


"""
 ----------------------------------------------------------------
 SPLIT CLIQUES AND WRITE TO FILE
 written by Chad Giusti, 11/2014
 Julia version by Emil Dmitruk 5/2019


 Given a list of maximal cliques in the clique complex of a
 thresholding of a matrix, use an iterative "splitting" method
 to compute cliques at successively lower threshold values.
 , writing subcliques of the appropriate dimension (at most
 two larger than the maximum betti) to a file for input to
 Perseus.

 INPUTS:
	symMatrix: the symmetric matrix whose order complex
       we are working with
   maxCliqueSize: maximum size of clique to enumerate
   maxDensity: maximum edge density -- stopping condition
   filePrefix: file prefix for output file
   writeMaxCliques: boolean flag for writing a file containing
       the maximal cliques -- may slow process substantially
----------------------------------------------------------------
"""
function split_cliques_and_write_to_file(symMatrix, maxCliqueSize, maxDensity,
                                                    filePrefix, writeMaxCliques)

    # ## Testing code:
    # symMatrix = inputMatrix
    # maxCliqueSize = maxBettiNumber + 2
    # maxDensity = edgeDensity
    # filePrefix = filePrefix
    # writeMaxCliques = writeMaxCliques
    # ## testing end.

    matrixSize = size(symMatrix, 1)
    thresholdedMatrix = 0
    edgeList = 0

    mat"[ $thresholdedMatrix, $edgeList ] = threshold_graph_by_density(...
        $symMatrix, $maxDensity );"

    maxFiltration = length(edgeList)

    if (maxDensity < 1)
        mat"maximalGraph = Graph(logical($thresholdedMatrix));"

        mat"initialMaxCliques = maximalGraph.GetCliques(1,0, true);"
    else
        mat"initialMaxCliques = Collection(ones(1,matrixSize));"
    end

    #=----------------------------------------------------------------
     Count cliques in the family of graphs obtained by thresholding
     the input matrix at every density in [0, maxDensity], and write
     these to files in a format useable by Perseus to compute
     persistent homology.
     --------------------------------------------------------------=#
    maxCliqueMatrix = 0
    brokenCliqueMatrix = 0
    mat"$maxCliqueMatrix = initialMaxCliques.ToMatrix();"
    file_cliq_name = "$(filePrefix)_simplices.txt"
    file_cliq_max_name = "$(filePrefix)_max_simplices.txt"
    cliqueFid = 0

    try
        cliqueFid = open(file_cliq_name, "w")
        write(cliqueFid,"1\n")
        close(cliqueFid)

        if writeMaxCliques
            cliqueMaxFid = open(file_cliq_max_name, "w")
            write(cliqueMaxFid,"1\n")
            close(cliqueMaxFid)
        end
        ## --------
        for i=length(edgeList):-1:1
            coordinates = findall(x->x==edgeList[i], symMatrix)[1]
            firstVertex = coordinates[1];
            secondVertex = coordinates[2];

            mat"[$maxCliqueMatrix, $brokenCliqueMatrix] =...
                find_and_split_cliques_containing_edge( $maxCliqueMatrix,...
                [$firstVertex, $secondVertex] );"
            # println(size(maxCliqueMatrix))

            brokenCliqueSets = Dict()
            for k=1:size(brokenCliqueMatrix,1)
                brokenCliqueSets[k] =  findall(x->x>0, brokenCliqueMatrix[k,:])
            end


            allBrokenCliques = restrict_max_cliques_to_size(brokenCliqueSets, maxCliqueSize, firstVertex, secondVertex)
            print_clique_list_to_perseus_file(allBrokenCliques, file_cliq_name, i);

            if writeMaxCliques
                print_clique_list_to_perseus_file(brokenCliqueSets,
                                                            file_cliq_max_name, i);
            end
            #=----------------------------------------------------------------
             Ensure all vertices appear on their own in the complex
             ---------------------------------------------------------------=#

            vertexSet = Dict()
            for i=1:matrixSize
                vertexSet[i] = i * ones(1);
            end

            print_clique_list_to_perseus_file(vertexSet, file_cliq_name, 1);

            if writeMaxCliques
                print_clique_list_to_perseus_file(vertexSet, file_cliq_max_name, 1);
            end

        end
    catch
        println("Something went wrong")
    end
    return maxFiltration
end


""" ----------------------------------------------------------------
 READ PERSISTENCE INTERVAL DISTRIBUTION
 written by Chad Giusti, 6/2014

 Read the distribution of persistence interval lengths for a
 particular homological dimension from Perseus output files.

 INPUT:
   fileName: Name of the file to read, with complete path if not
       the working directory

 OUTPUT:
   distribution: An array containing a the distribution of interval
       lengths. The final element is for "infinite" intervals with
       no endpoint.
 -------------------------------------------------------------"""
function read_persistence_interval_distribution(fileName, numFiltrations)
    distribution = zeros(1, numFiltrations);
    infinite_intervals = 0;

    # ----------------------------------------------------------------
    # Open the file and read the outputs into the array

    if isfile(fileName)
        try
            fid = open(fileName, "r")
            for line in eachline(fid)
                A = split(line)
                interval = [parse(Int64, A[1]) parse(Int64, A[2])]
                # println(interval[end])
                if (interval[end] == -1)
                    infinite_intervals = infinite_intervals + 1;
                else
                    len = interval[end] - interval[1];
                    distribution[len] = distribution[len]+1;
                end
            end
            close(fid)
        catch exception
            # disp(exception.message);
            rethrow(exception);
        end
    end
    return distribution, infinite_intervals
end


"""
 ----------------------------------------------------------------
 READ PERSEUS BETTIS
 written by Chad Giusti, 6/2014
%
 Read the betti numbers output by Perseus into an integer array
%
 INPUT:
   fileName: Name of the file to read, with complete path if not
       the working directory
   maxFilt: Maximum filtration level/frame from which to read
       simplices from. The function will read inputs in the
       range 1-maxFilt.
   maxDim: The maximum Betti number to read
   betti0: Boolean flag indicating whether to discard Betti 0.
%
 OUTPUT:
   bettis: A maxFilt x maxDim array of integers whose (i,j)
       entry is the number of cycles of dim j appearing
       in the ith filtration level. If betti0 is true, the array
       is instead maxFilt x (maxDim+1) and cycles of dim j
       are recorded in column j+1.
%
 ----------------------------------------------------------------"""
function read_perseus_bettis(fileName, maxFilt, maxDim, betti0 )

    # Tet code:
# fileName = fileName
# maxFilt = numFiltrations
# maxDim = maxBettiNumber
# betti0 = computeBetti0

    # end test
    bettis = 0

    try
        fid = open(fileName, "r")
        lines = readlines(fid)

        tline = lines[2] # get first line and extract number of columns
        # Get rid of white spaces at the beginning and at the end
        # while tline[end] == ' '
        tline = tline[1:end-1]
        # end
        # while tline[1] == ' '
        tline = tline[2:end]
        # end
        elements = split(tline, " ")
        close(fid)

        numCols = size(elements,1)
        numRows = size(lines, 1) - 1
        bettis = zeros(Int64, maxFilt, numCols - 1)

        fid = open(fileName, "r")

        row = 1
        for line in eachline(fid)

            if length(line) <= 1
                # skip
            else
                line = line[2:end-1]
                elements = split(line, " ")
                for j = 2:numCols
                    bettis[row, j-1] = parse(Int64, elements[j])
                end
                row += 1
            end
        end
        close(fid)
    catch exception
        # disp(exception.message);
        rethrow(exception);
    end

     # ----------------------------------------------------------------
     # Perseus does not output data for filtrations where nothing changes
     # homologically. Fill these in in the matrix -- detect by checking
     # that betti 0 is zero.
     # ----------------------------------------------------------------

    for i=2:maxFilt
        if bettis[i,1] == 0
            bettis[i,:] = bettis[i-1,:];
        end
    end
     # ----------------------------------------------------------------
     # Drop the Betti 0 information if indicated.
     # ----------------------------------------------------------------

    if betti0
        bettis = bettis[:,1:min(maxDim+1, size(bettis,2))];
    else
        bettis = bettis[:,2:min(maxDim+1, size(bettis,2))];
    end
    return bettis
end

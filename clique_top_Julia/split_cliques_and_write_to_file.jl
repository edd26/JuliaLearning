include("restrict_max_cliques_to_size.jl")
include("print_clique_list_to_perseus_file.jl")

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
function split_cliques_and_write_to_file(symMatrix, maxCliqueSize, maxDensity, filePrefix, writeMaxCliques)

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
    % Count cliques in the family of graphs obtained by thresholding
    % the input matrix at every density in [0, maxDensity], and write
    % these to files in a format useable by Perseus to compute
    % persistent homology.
    % --------------------------------------------------------------=#
    maxCliqueMatrix = 0
    brokenCliqueMatrix = 0
    mat"$maxCliqueMatrix = initialMaxCliques.ToMatrix();"

    try
        cliqueFid = open("$(filePrefix)_simplices.txt", "w")
        write(cliqueFid,"1\n")
        close(cliqueFid)
        cliqueFid = open("$(filePrefix)_simplices.txt", "a")


        if writeMaxCliques
            cliqueMaxFid = open("$(filePrefix)_max_simplices.txt", "w")
            write(cliqueMaxFid,"1\n")
            close(cliqueMaxFid)
            cliqueMaxFid =  open("$(filePrefix)_max_simplices.txt", "a")
        end

        ## --------
        for i=length(edgeList):-1:1
            coordinates = findall(x->x==edgeList[i], symMatrix)[1]
            firstVertex = coordinates[1];
            secondVertex = coordinates[2];

            mat"[$maxCliqueMatrix, $brokenCliqueMatrix] =...
                find_and_split_cliques_containing_edge( $maxCliqueMatrix,...
                [$firstVertex, $secondVertex] );"

            brokenCliqueSets = Dict()
            for k=1:size(brokenCliqueMatrix,1)
                brokenCliqueSets[k] =  findall(x->x>0, brokenCliqueMatrix[k,:])
            end

            if writeMaxCliques
                print_clique_list_to_perseus_file(brokenCliqueSets, cliqueMaxFid, i);
            end

            allBrokenCliques = restrict_max_cliques_to_size(brokenCliqueSets, maxCliqueSize, firstVertex, secondVertex)
            print_clique_list_to_perseus_file(allBrokenCliques, cliqueFid, i);


            #=----------------------------------------------------------------
            % Ensure all vertices appear on their own in the complex
            % ---------------------------------------------------------------=#

            vertexSet = Dict()
            for i=1:matrixSize
                vertexSet[i] = i * ones(1);
            end

            print_clique_list_to_perseus_file(vertexSet, cliqueFid, 1);

            if writeMaxCliques
                print_clique_list_to_perseus_file(vertexSet, cliqueMaxFid, 1);
            end
        end
    finally
        close(cliqueFid)

        if writeMaxCliques
            close(cliqueMaxFid)
        end
    end
    return maxFiltration
end

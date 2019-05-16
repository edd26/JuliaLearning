using Combinatorics
using DelimitedFiles
using MATLAB
using LinearAlgebra
using Match
using DelimitedFiles
using Plots
include("../GeometricMatrix.jl")

testing = false


"""
----------------------------------------------------------------
BASED ON THE:
COMPUTE CLIQUE TOPOLOGY
written by Chad Giusti, 9/2014

Given a symmetric real matrix, construct its order complex, a
 family of graphs filtered by graph density with edges added in
 order of decreasing corrsponding entry in the matrix. Enumerate
 cliques in this family of graphs and run Perseus to compute the
 persistent homology of the resulting clique complexes. Return
 both the aggregate Betti curves and the distribution of
 persistence lifetimes for the order complex of the matrix.

 SYNTAX:
  compute_clique_topology( inputMatrix )
  compute_clique_topology( inputMatrix, "ParameterName", param, ... )

 INPUTS:
	inputMatrix: an NxN symmetric matrix with real coefficients
 OPTIONAL PARAMETERS:
   "ReportProgress": displays status and time elapsed in each stage
       as computation progresses (default: false)
   "MaxBettiNumber": positive integer specifying maximum Betti
 	number to compute (default: 3)
   "MaxEdgeDensity": maximum graph density to include in the
	order complex in range (0, 1] (default: .6)
   "FilePrefix": prefix for intermediate computation files,
	useful for multiple simultaneous jobs
	(default: "matrix")
   "ComputeBetti0": boolean flag for keeping Betti 0
       computations; this shifts the indexing of the
       outputs so that column n represents Betti (n-1).
       (default: false)
   "KeepFiles": boolean flag indicating whether to keep
	intermediate files when the computation
	is complete (default: false)
   "WorkDirectory": directory in which to keep intermediate
       files during computation (default: current
	directory, ".")
   "BaseDirectory": location of the CliqueTop matlab files
       (default: detected by which("compute_clique_topology"))
   "writeMaxCliques": boolean flag indicating whether
       to create a separate file containing the maximal cliques
       in each graph. May slow process. (default: false)
   "Algorithm": which version of the clique enumeration algorithm
       to use. Options are: "split", "combine" and "naive". "split"
       is the version used for the data processing in "Clique topology
       reveals intrinsic structure in neural correlations". It is
       usually the most memory-efficient algorithm, but requires the
       user to "guess" a maximum density and compute a list of cliques
       using Cliquer, which must also be compiled using MEX. "combine"
       is much less memory efficient, but constructs a list of maximal
       cliques starting from the first filtration and building upward.
       "naive" does not construct maximal cliques, but instead enumerates
       all cliques of sizes necessary to compute Bettis in the specified
       range. It is very memory efficient but slow, and works well for
       large matrices. It is incompatible with "writeMaxCliques".

 OUTPUTS:
   bettiCurves: rectangular array of size
	maxHomDim x floor(maxGraphDensity * (N choose 2))
	whose rows are the Betti curves B_1 ... B_maxHomDim
	across the order complex
   edgeDensities: the edge densities of the graphs in the
       order complex, useful for x-axis labels when graphing
	persistenceIntervals: rectangular array of size
	maxHomDim x floor(maxGraphDensity * (N choose 2))
       whose rows are counts of the persistence lifetimes
       in each homological dimension.
   unboundedIntervals: vector of length maxHomDim whose
       entries are the number of unbounded persistence intervals
   for each dimension. Here, unbounded should be interpreted
       as meaning that the cycle disappears after maxGraphDensity
       as all cycles disappear by density 1.

 ---------------------------------------------------------------"""
function compute_clique_topology(inputMatrix;
                                    reportProgress = false,
                                    maxBettiNumber = 3,
                                    edgeDensity = .6,
                                    computeBetti0 = false,
                                    filePrefix = "matrix",
                                    keepFiles = false,
                                    workDirectory = ".",
                                    writeMaxCliques = false,
                                    algorithm = "split",
                                    threads = 1,
                                    delete_existing_files = true)

# # For testing only:
#
# #
# matrix_size = 40
#     reportProgress = false
#     maxBettiNumber = 3
#     edgeDensity = .6
#     computeBetti0 = false
#     filePrefix = "matrix"
#     keepFiles = false
#     workDirectory = "."
#     writeMaxCliques = false
#     algorithm = "split"
#     threads = 1
#     delete_existing_files = true
#
#     geometric_matrix = readdlm( "geometric_matrix.csv",  ',', Float64, '\n')
#     inputMatrix = geometric_matrix[1:matrix_size,1:matrix_size]
# end testing

    # ----------------------------------------------------------------
    # Validate and set parameters
    it_is = false
    change_folder = true

    current_location = pwd()
    folders = split(current_location, "/")

    for element in folders
        if occursin("clique_top_Julia", element) #&& it_is
            change_folder = false
        end
    end
    mat"cd('/home/ed19aaf/Programming/Julia/JuliaLearning/clique_top_Julia')"

    try
        if change_folder
            cd("clique_top_Julia/")

            mat"pwd"
        end
    catch y
       println("Can not enter clique_top_Julia")
       println("Currentlny in folder:")
       println(pwd())
   end



    baseDirectory = pwd()
    functionLocation = baseDirectory*"/compute_clique_topology.m"

    perseusDirectory = baseDirectory*"/perseus"
    neuralCodewareDirectory = baseDirectory*"/Neural_Codeware"

    if (algorithm == "naive") || (algorithm=="parnaive") && writeMaxCliques
        error("Naive clique enumeration and writeMaxCliques are incompatible");
    end

    if (algorithm == "parnaive")
        # empty in original file
    end

    # ----------------------------------------------------------------
    # If we need Cliquer, make sure the files are compiled
    if (algorithm == "split")
        if isfile("./clique_top/Neural_Codeware/+Cliquer/FindAll.mexa64")
            println("MEX Cliquer not compiled. Compiling before beginning process.")

            startFolder = baseDirectory
            # It needs to be checked what is tha execution dir of this funciton
            cd("Neural_Codeware");
            # cd("clique_top/Neural_Codeware");

            # Compiler.compile()
            # What compile does it compiles the c file and create mex file so that the c object can be used in matlab. The latter is not necessary

            # The directory in which the Cliquer source code resides.
            strDir = string(pwd(), "/+Cliquer", "/cliquer");

            # clean old stuff
            run(`make -C $strDir clean`);

            # Build cliquer.
            run(`make -C $strDir`);

            # TODO Files are not moved anywhere

            cd(startFolder);
        end
    end

    # ----------------------------------------------------------------
    # Ensure that the diagonal is zero
    # ensure by zeroing the diagonal
    inputMatrix[Matrix{Bool}(I, size(inputMatrix))] .= 0

    # ----------------------------------------------------------------
    # Move to working directoy and stop if files might be overwritten
    mat"path($neuralCodewareDirectory, path);";
    try
        cd(workDirectory);
        if isfile(workDirectory * "/" * filePrefix * "_max_simplices.txt")
            if delete_existing_files
                println("File $(filePrefix)_max_simplices.txt already exists but will be removed")
                run(`rm $(filePrefix)_max_simplices.txt`)
            else
                error("File $(filePrefix)_max_simplices.txt already exists in directory $(workDirectory).");
            end

        end
        if isfile(workDirectory * "/" * filePrefix * "_simplices.txt")
            if delete_existing_files
                println("File $(filePrefix)_simplices.txt already exists but will be removed")
                run(`rm $(filePrefix)_simplices.txt`)
            else
                error("File $(filePrefix)_simplices.txt already exists in directory $(workDirectory).");
            end
        end
        if isfile(workDirectory * "/" * filePrefix * "_homology_betti.txt")
            if delete_existing_files
                println("File $(filePrefix)_homology_betti.txt already exists but will be removed")
                run(`rm $(filePrefix)_homology_betti.txt`)
            else
                error("File $(filePrefix)_homology_betti.txt already exists in directory $(workDirectory).");
            end
        end

        for d=0:maxBettiNumber+1
            if isfile(workDirectory * "/" * filePrefix * "_homology_" * string(d) *  ".txt")
                if delete_existing_files
                    println("File $(filePrefix)_homology_$(d).txt already exists but will be removed")
                    run(`rm $(filePrefix)_homology_$(d).txt`)
                else
                    error("File ($filePrefix)_homology_($d).txt already exists in directory ($workDirectory).");
                end
            end
        end
    catch exception
        # disp(exception.message);
        rethrow(exception);
    end

    # ----------------------------------------------------------------
    # Enumerate maximal cliques and print to Perseus input file

    if reportProgress
        # toc;
        println("Enumerating cliques using $algorithm algorithm.");
        # tic;
    end

    if algorithm == "combine"
        mat"numFiltrations = combine_cliques_and_write_to_file(...
            inputMatrix, maxBettiNumber + 2, maxEdgeDensity, filePrefix,...
            writeMaxCliques);"
    elseif algorithm=="naive"
        mat"numFiltrations = naive_enumerate_cliques_and_write_to_file(...
            inputMatrix, maxBettiNumber + 2, maxEdgeDensity, filePrefix);"
    elseif algorithm=="parnaive"
        mat"numFiltrations = ...
            parallel_naive_enumerate_cliques_and_write_to_file(...
            inputMatrix, maxBettiNumber + 2, maxEdgeDensity, filePrefix,...
            numThreads );"
    elseif algorithm=="split"
        numFiltrations = split_cliques_and_write_to_file(inputMatrix, maxBettiNumber + 2, edgeDensity, filePrefix,writeMaxCliques)
    end

    # ----------------------------------------------------------------
    # Use Perseus to compute persistent homology

    if reportProgress
        # toc;
        println("Using Perseus to compute persistent homology.");
        # tic;
    end

    # run_perseus(filePrefix, perseusDirectory);
    if Sys.isapple()
        perseusCommand = "perseusMac"
    elseif Sys.iswindows()
        perseusCommand = "perseusWin"
    elseif Sys.islinux()
        perseusCommand = "perseusLin"
    else
        error("Cannot determine operating system type to run Perseus.");
    end

    run(`$perseusDirectory/$perseusCommand nmfsimtop $(filePrefix)_simplices.txt $(filePrefix)_homology`)

    if reportProgress
        # toc;
    end

    # ----------------------------------------------------------------
    # Assemble the results of the computation for output
    matrixSize = size(inputMatrix, 1)
    edgeDensities = (1:numFiltrations) / binomial(matrixSize,2)
    bettiCurves = 0
    persistenceIntervals = 0
    unboundedIntervals = 0

    try
        fileName = "$(filePrefix)_homology_betti.txt"
        bettiCurves = read_perseus_bettis(fileName, numFiltrations,
                                                    maxBettiNumber, computeBetti0)
        # mat"read_perseus_bettis(, $numFiltrations, $maxBettiNumber, $computeBetti0);"
#
        if computeBetti0
            persistenceIntervals = zeros(Int64(numFiltrations), maxBettiNumber+1);
            unboundedIntervals = zeros(1,maxBettiNumber+1);

            for d=0:maxBettiNumber
                fileName = ("$(filePrefix)_homology_$d.txt")
                A = read_persistence_interval_distribution(fileName, numFiltrations)
                persistenceIntervals[:,d] = A[1]
                unboundedIntervals[d] = A[2]
            end
        else
            persistenceIntervals = zeros(Int64(numFiltrations), maxBettiNumber);
            unboundedIntervals = zeros(1,maxBettiNumber);

            for d=1:Int64(maxBettiNumber)
                fileName = ("$(filePrefix)_homology_$d.txt")
                A = read_persistence_interval_distribution(fileName, numFiltrations)
                persistenceIntervals[:,d] = A[1]
                unboundedIntervals[d] = A[2]
            end
        end
    catch exception
        # println(exception.message);
        println("Failure to read Perseus output files. This error has likely occurred due to the Perseus process aborting due to memory limitations. It may be possible to circumvent this difficulty by reducing either the maximum Betti number or the maximum edge density computed. Please see the CliqueTop documentation for details.");
        rethrow(exception);
    end


    # ----------------------------------------------------------------
    # Remove remaining intermediate files if desired

    if keepFiles == false
        try
            max_simp_path = string(workDirectory, "/", filePrefix, "_max_simplices.txt")
            if isfile(max_simp_path)
                run(`rm $max_simp_path`)
            end

            simp_path = string(workDirectory, "/", filePrefix, "_simplices.txt")
            if isfile(simp_path)
                run(`rm $simp_path`)
            end

            hom_betti_path = string(workDirectory, "/", filePrefix, "_max_simplices.txt")
            if isfile(hom_betti_path)
                run(`rm $hom_betti_path`)
            end

            for d=0:maxBettiNumber+1
                max_betti_path = string(workDirectory, "/", filePrefix, "_homology_", string(d), ".txt")
                if isfile(max_betti_path)
                    run(`rm $max_betti_path`)
                end
            end
        catch exception
            println(exception.message);
            rethrow(exception);
        end
    end

    return bettiCurves, edgeDensities, persistenceIntervals, unboundedIntervals
end








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
    if false
        maximalCliques = brokenCliqueSets
        maxSize = maxCliqueSize
        firstVertex = firstVertex
        secondVertex = secondVertex
    end
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
    if false
        cliques = brokenCliqueSets
        fid = cliqueFid
    end
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
    if false
    symMatrix = inputMatrix
    maxCliqueSize = maxBettiNumber + 2
    maxDensity = edgeDensity
    filePrefix = filePrefix
    writeMaxCliques = writeMaxCliques
    end
    # ## testing end.

    matrixSize = size(symMatrix, 1)
    thresholdedMatrix = 0
    edgeList = 0
    #maximalGraph = 0
    # initialMaxCliques = 0

    mat"[$thresholdedMatrix, $edgeList] = threshold_graph_by_density($symMatrix, $maxDensity );"

    maxFiltration = length(edgeList)

    if (maxDensity < 1)
        mat"maximalGraph = Graph(logical($thresholdedMatrix));"

        mat"initialMaxCliques = maximalGraph.GetCliques(1,0, true);"
    else
        mat"initialMaxCliques = Collection(ones(1,$matrixSize));"
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

using MATLAB
 using LinearAlgebra
 using Match
 using DelimitedFiles
 using Plots
 include("../MatrixToolbox.jl")
 include("CliqueTop.jl")


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
#
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

    try
        if change_folder
            cd("clique_top_Julia/")
            mat"cd('clique_top_Julia')"
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

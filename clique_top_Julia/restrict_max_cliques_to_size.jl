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
function restrict_max_cliques_to_size(maximalCliques, maxSize, firstVertex,secondVertex)
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
            subVertices = vertices[findall(x-> (x!= firstVertex) && (x!= secondVertex), vertices)]
                # all new cliques will contain the edge removed at this filtration
                # level
            theseSmallCliques = collect(combinations(subVertices, maxSize-2))

            for k=1:size(theseSmallCliques,1)
                restrictedCliques[thisSmallClique] = [theseSmallCliques[k,:][1]; firstVertex;  secondVertex];
                thisSmallClique = thisSmallClique + 1;
            end
        end
    end

    return restrictedCliques
end

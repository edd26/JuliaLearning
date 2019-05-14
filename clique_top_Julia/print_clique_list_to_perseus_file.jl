#=----------------------------------------------------------------
% PRINT CLIQUE LIST TO PERSEUS FILE
% written by Chad Giusti, 6/2014
%
% Output a cell array of cliques in a particular filtration level
% to the file given by fid in the Perseus non-manifold simplicial complex
% format: each line corresponds to a single clique, and is given by the
% size of the clique, then the vertices, then the filtration level
%
% INPUT:
%   cliques: cell array whose elements are positive integer vectors with
%       entries giving the vertices of cliques in a graph
%   fid: file into which to print the cliques
%   filtration: filtration number with which to tag these cliques
%
% ---------------------------------------------------------------- =#
function print_clique_list_to_perseus_file(cliques, filePrefix, filtration)

    open("$(filePrefix)_simplices.txt", "a") do cliqueFid
        for j=1:length(cliques)
            write(cliqueFid,"$(size(cliques{j},2)-1))")
            for k=1:(size(cliques{j},2))
                write(cliqueFid,"$(cliques{j}(k))")
            end
            write(cliqueFid,"$(filtration)\n")
        end

    end
end

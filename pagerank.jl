"""
Julia code for 21-241 F21 Final Project created by Allen Gao and Evan Zhang.
"""

using LinearAlgebra
using Random
using StatsBase
using Statistics
using Plots

function parse_file(file)
    """
    INPUT: file name; the file is initialized 
        such that the 1st row is the number of 
        nodes and each subsequent node
        has a fromId and toId
    OUTPUT: adjacency matrix, number of nodes
    - Includes teleportation
    """
    data = readlines(file) # read all lines from file
    numNodes = parse(Int32, data[1]) # extract number of nodes
    A = fill(float(0), (numNodes, numNodes)) # initialize adjacency matrix
    hasOutNode = fill(0, numNodes) # initialize "visited" matrix
    for i in 2:(size(data)[1])
        edge = split(data[i])
        fromId = parse(Int32, edge[1])
        toId = parse(Int32, edge[2])
        A[toId, fromId] = 1 # fromId is the column, toId is the row
        if hasOutNode[fromId] == 0
            hasOutNode[fromId] = 1 # update "visited" matrix
        end
    end

    # Teleportation Implementation
    for i in 1:numNodes
        if hasOutNode[i] == 0
            A[:, i] .= 1 # visits all other nodes
        end
    end

    return A, numNodes
end

function pagerank(file, iter, damp, plotting=false)
    """
    INPUT: file name (STR), number of iterations (INT), damping factor (FLOAT)
    OUTPUT: An array A where the ith index in the array is A[i]th most important
    - Uses the iterative method
    """
    A, n = parse_file(file)
    A  = A ./ sum(A, dims=1) # normalize each column in the matrix
    v = rand!(zeros(n)) # create a n-element matrix of zeros
    v /= norm(v, 1) # use 1-norm
    A_hat = (damp * A .+ (1 - damp) / n) # pagerank algorithm
    plotArray = fill(float(0), (iter+1, n)) # initialize plot array
    plotArray[1, :] = v # start with initial
    for x in 1:iter
        v = A_hat * v
        plotArray[x+1, :] = v
    end

    #print("Page rank scores are: ", v, "\n")
    if plotting
        savefig(plot(1:iter+1, plotArray, xlabel="iterations", ylabel="score"), replace(file, ".txt" => "-") * string(iter) * "-plot.png")
    end

    return ordinalrank(v, rev=true)
end

function hits(file, iter, plotting=false)
    """
    INPUT: file name (STR), number of iterations (INT)
    OUTPUT: An array A with the authority scores in the 1st column and the
        hub scores in the 2nd column
    """
    A, n = parse_file(file)
    scoresData = fill(float(1), (n, 2)) # auth, hub; initialized with 1
    authPlotArray = fill(float(1), (iter+1, n)) # initialize auth plot array
    hubPlotArray = fill(float(1), (iter+1, n)) # initialize hub plot array
    for x in 1:iter
        # Update authority values first
        norm = 0
        for i in 1:n
            auth = 0
            for j in 1:n
                if A[i, j] == 1
                    auth += scoresData[j, 2]
                end
            end
            norm += (auth * auth)
            scoresData[i, 1] = auth
        end
        norm = sqrt(norm)
        scoresData[:, 1] = scoresData[:, 1] ./ norm # update the auth scores
        norm = 0
        for i in 1:n
            # Then update hub values
            hub = 0
            for j in 1:n
                if A[j, i] == 1
                    hub += scoresData[j, 1]
                end
            end
            norm += (hub * hub)
            scoresData[i, 2] = hub
        end
        norm = sqrt(norm)
        scoresData[:, 2] = scoresData[:, 2] ./ norm # update the hub scores

        authPlotArray[x+1, :] = scoresData[:, 1]
        hubPlotArray[x+1, :] = scoresData[:, 2]
    end
    
    if plotting
        savefig(plot(1:iter+1, authPlotArray, xlabel="iterations", ylabel="auth score"), replace(file, ".txt" => "-") * string(iter) * "-auth-plot.png")
        savefig(plot(1:iter+1, hubPlotArray, xlabel="iterations", ylabel="hub score"), replace(file, ".txt" => "-") * string(iter) * "-hub-plot.png")
    end

    #display(scoresData)
    #print("\n")
    return ordinalrank(scoresData[:, 1], rev=true), ordinalrank(scoresData[:, 2], rev=true)
end

function generate_random(file_loc, numNodes, iter, fac=1)
    """
    INPUT: file location (STR), number of nodes (INT), number of iterations (INT), sparsity factor (INT)
    OUTPUT: Writes file which consists of randomly generated adjacency matrix
    """
    for x in 1:iter
        A = rand(append!(zeros(fac), 1), numNodes, numNodes) # random adjacency matrix
        io = open(file_loc*"/i"*string(x)*"n"*string(numNodes)*"f"*string(fac)*".txt", "w") # Create file
        println(io, string(numNodes)) # write number of nodes to file
        for i in 1:numNodes
            for j in 1:numNodes
                if A[i, j] == 1
                    println(io, string(j)*" "*string(i)) # write the adjacency pairing to file
                end
            end
        end
        close(io) # close file
    end
end

function comparison(file)
    """
    INPUT: file directory
    OUTPUT: Correlation scores ap_c, hp_c, and ah_c
    """
    dir = readdir(file)
    authPlotArray = fill(float(0), size(dir))
    hubPlotArray = fill(float(0), size(dir))
    hitsPlotArray = fill(float(0), size(dir))
    c = 1
    for i in dir
        fileName = file*i # concatenate for file name
        ranks = pagerank(fileName, 10, 0.85)
        authScores, hubScores = hits(fileName, 10)
        authPlotArray[c] = cor(ranks, authScores)
        hubPlotArray[c] = cor(ranks, hubScores)
        hitsPlotArray[c] = cor(authScores, hubScores)
        c += 1
    end

    return authPlotArray, hubPlotArray, hitsPlotArray
end

"""
ranks = pagerank("allen.txt", 10, 0.85, false)
print(ranks, "\n")

authScores, hubScores = hits("allen.txt", 10, false)
print(authScores, "\n")
print(hubScores, "\n")

print("Correlation between ranks and auth scores: ", cor(ranks, authScores))
print("\nCorrelation between ranks and hub scores: ", cor(ranks, hubScores))
"""

"""
generate_random("random/100x1", 100, 25, 1)
generate_random("random/100x3", 100, 25, 3)
generate_random("random/100x15", 100, 25, 15)
generate_random("random/100x99", 100, 25, 99)
"""

"""
authPlotArray, hubPlotArray, hitsPlotArray = comparison("random/100x99/")
print("Auth and PageRank: ", mean(authPlotArray), "\n")
print("Hub and PageRank: ", mean(hubPlotArray), "\n")
print("Auth and Hub: ", mean(hitsPlotArray), "\n")
"""

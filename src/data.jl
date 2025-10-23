module data

#using Statistics
#using Random
using Graphs, SimpleWeightedGraphs

struct instData
    N::Int # #nodes
    M::Int # #edges
    G
end

export instData, readData

function readData(instanceFile, params)
    file = open(instanceFile)
    fileText = read(file, String)
    tokens = split(fileText) 
    # tokens will have all the tokens of the input file in a single vector. 
    # We will get the input token by token

    # read the problem's dimensions N
    aux = 1
    N = parse(Int,tokens[aux])
    aux += 1
    M = parse(Int,tokens[aux])
    
    G = SimpleWeightedGraph(N)
    
    for t in 1:M
        aux += 1
        i = parse(Int, tokens[aux])
        aux += 1
        j = parse(Int, tokens[aux])
        aux += 1
        edge = parse(Int, tokens[aux])
        #println(i,j,e)
        add_edge!(G, i, j, edge)
    end

    close(file)

    inst = instData(N,M,G)

    return inst

end

end

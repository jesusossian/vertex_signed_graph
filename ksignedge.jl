push!(LOAD_PATH, "src/")
# push!(DEPOT_PATH, JULIA_DEPOT_PATH)

#using Pkg
#Pkg.activate(".")
#Pkg.instantiate()
#Pkg.build()

using JuMP
using Gurobi
using CPLEX
using Graphs, SimpleWeightedGraphs
using GraphPlot

import data
import parameters
import edgeFormulation

params = parameters.readParameters(ARGS)

#julia ksigned.jl --inst instancia --form ${form} 

# read instance data
inst = data.readData(params.instName, params)

if (params.form == "edge")
    edgeFormulation.edgeForm(inst,params)
end

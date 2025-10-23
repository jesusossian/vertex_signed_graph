module edgeFormulation

using JuMP
using Gurobi
using CPLEX
using SCIP
using data
using parameters

using Graphs, SimpleWeightedGraphs
using GraphPlot

mutable struct stdVars
    y
    x
end

export edgeForm, stdVars

function edgeForm(inst::instData, params::parameterData)

    N = inst.N
    M = inst.M
    
    k = params.numbk
    
    nodes = vertices(inst.G)
    
    vk = Set()
    for i in nodes
        for j in 1:k
            a = (i,j)
            push!(vk, a)
        end
    end
    
    EN = Set()
    for e in edges(inst.G)
        if inst.G[e, Val(:weight)] == -1
            push!(EN, e) 
            #println(G[e, Val(:weight)])
            #println(get_weight(G, e))
        end
    end
    
    EP = Set()
    for e in edges(inst.G)
        if inst.G[e, Val(:weight)] == 1
            push!(EP, e) 
            #println(G[e, Val(:weight)])
            #println(get_weight(G, e))
        end
    end
    
    ### select solver and define parameters ###
    if params.solver == "gurobi"  
        model = Model(Gurobi.Optimizer)
        set_optimizer_attribute(model,"TimeLimit",params.maxtime) # time limit
        set_optimizer_attribute(model,"MIPGap",params.tolgap) # relative MIP optimality gap
        #set_optimizer_attribute(model,"NodeLimit",params.maxnodes) 
        set_optimizer_attribute(model,"Threads",params.threads) # number of threads
        #set_optimizer_attribute(model,"Method",-1) # method used in root node
        #set_optimizer_attribute(model,"NodeMethod",0) # method used to solve MIP node relaxations
        #set_optimizer_attribute(model,"SolutionLimit",1) # first viable solution
        set_optimizer_attribute(model,"Presolve",params.presolve)
        set_optimizer_attribute(model,"Cuts",params.cuts)
        set_optimizer_attribute(model,"MIPFocus",params.mipfocus)
        set_optimizer_attribute(model,"NodefileStart",0.5)
        set_optimizer_attribute(model,"NodefileDir","/report")
    elseif params.solver == "cplex"
        model = Model(CPLEX.Optimizer)
        set_optimizer_attribute(model,"CPX_PARAM_TILIM",params.maxtime) # time limit
        set_optimizer_attribute(model,"CPX_PARAM_EPGAP",params.tolgap) # relative MIP optimality gap
        #set_optimizer_attribute(model,"CPX_PARAM_LPMETHOD",0) # method used in root node
        set_optimizer_attribute(model,"CPX_PARAM_NODELIM",params.maxnodes) # MIP node limit
        set_optimizer_attribute(model,"CPX_PARAM_THREADS",params.threads) # number of threads    
    elseif params.solver == "scip"
        model = Model(SCIP.Optimizer)
    else
        println("no solver selected")
        return 0
    end

    ### variables ###
    @variable(model, x[vk], Bin)
    @variable(model, y[edges(inst.G)], Bin)
    
    ### objective function ###
    @objective(model, Min, sum(y[e] for e in edges(inst.G)))

    ### constraints ###
    for v in nodes
        @constraint(model, sum(x[(v,i)] for i=1:k) >= 1.0)
    end
    
    for e in EN
        u = src(e)
        v = dst(e)
        for i in 1:k
            @constraint(model, x[(u,i)] + x[(v,i)] <= 1 + y[e])
        end
    end
    
    for e in EP
        u = src(e)
        v = dst(e)
        for i in 1:k
            @constraint(model, x[(u,i)] >= x[(v,i)] - y[e])
        end
    end
    
    for e in EP
        u = src(e)
        v = dst(e)
        #println(e)
        for i in 1:k
            @constraint(model, x[(v,i)] >= x[(u,i)] - y[e])
        end
    end
  
    # write_to_file(model,"ksigned.lp")

    ### solving the problem ###
    optimize!(model)
  
    ### get status ###
    opt = 0
    if termination_status(model) == MOI.OPTIMAL    
        println("status = ", termination_status(model))
        opt = 1
    else
        println("status = ", termination_status(model))
    end
    
    ### get solutions ###
    if params.method == "mip"
        obound = objective_bound(model)
        nnodes = node_count(model)
        mgap = MOI.get(model,MOI.RelativeGap())
    end
    oval = objective_value(model)
    rtime = solve_time(model)

    ### print solutions ###
    open("saida.txt","a") do f
        if params.method == "mip"
            write(f,"$(params.instName);$(params.form);$(params.method);$(obound);$(oval);$(mgap);$(rtime);$(nnodes);$(opt)\n")
        else
            write(f,"$(params.instName);$(params.form);$(params.method);$(oval);$(rtime)\n")
        end
    end
  
end

end

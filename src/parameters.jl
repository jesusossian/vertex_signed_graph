module parameters

struct parameterData
    instName::String
    numbk::Int
    form::String
    solver::String
    method::String
    maxtime::Int
    tolgap::Float64
    disablesolver::Int
    maxnodes::Int
    threads::Int
    presolve::Int
    cuts::Int
    mipfocus::Int
end

export parameterData, readParameters

function readParameters(ARGS)

    ### Set standard values for the parameters ###
    instName = "data/kmbs/instances/RANDOM/random_n20_k2_pos30_neg5_err5_1.g"
    numbk = 3
    form = "edges"
    solver = "scip"
    method = "mip"
    maxtime = 3600
    tolgap = 1e-6
    disablesolver = 0
    maxnodes = 10000000.0
    threads = 1
    presolve = -1 # default -1
    cuts = -1 # default -1
    mipfocus = 0 # default 0

    ### Read the parameters and setvalues whenever provided ###
    for param in 1:length(ARGS)
        if ARGS[param] == "--inst"
            instName = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--nk"
            numbk = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--form"
            form = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--solver"
            solver = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--method"
            method = ARGS[param+1]
        end
    end

    params = parameterData(
        instName,
        numbk,
        form,
        solver,
        method,
        maxtime,
        tolgap,
        disablesolver,
        maxnodes,
        threads,
        presolve, 
        cuts,
        mipfocus
    )

    return params

end 

end

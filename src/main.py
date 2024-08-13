from pathlib import Path
import os
import networkx as nx
import gurobipy as gp

import sys

if __name__ == "__main__":

    results_path = Path('result/')
    instance_path = Path('data/kmbs/instances/RANDOM')
    out_path = Path('/home/jossian/Downloads/develop/report/signed_graphs')

    # instance
    if len(sys.argv) < 2:
        print("input instance")
    else:
        method = sys.argv[1]
        instance = sys.argv[2]
    
    data = os.path.join(instance_path,instance)
        
    with open(data, 'r') as file:
        lines = file.readlines()

    lines = [a.strip() for a in lines]

    values = lines[0].split()
    n, m = int(values[0]), int(values[1])

    # network
    G = nx.Graph()

    for k in range(n):
        G.add_node(k)

    for e in range(1,m+1):   
        values = lines[e].split()
        i, j, val = int(values[0]), int(values[1]), int(values[2])
        G.add_edge(i, j, weight=val)

    # sets
    nodes = G.nodes()
    edges = G.edges()

    EP = [(u, v) for (u, v, d) in G.edges(data=True) if d["weight"] > 0]
    EN = [(u, v) for (u, v, d) in G.edges(data=True) if d["weight"] < 0]

    A = []
    for i in nodes:
        neighbors = G.neighbors(i)
        lst = []
        for j in neighbors:
            if G[i][j]["weight"] < 0:
                lst.append(j)
        lst.append(i)
        lstCoV =  list(set(nodes) - set(lst))
        for j in lstCoV:
            if (i<j):
                a = (i,j)
                A.append(a)
        
    A0 = A
    for i in nodes:
        a = (i,i)
        A0.append(a)
        
    D = []
    for i in nodes:
        lst = []
        for j in nodes:
            if (i,j) in A0:
                lst.append(j)
        D.append(lst)        

    O = []
    for j in nodes:
        lst = []
        for i in nodes:
            if (i,j) in A0:
                lst.append(i)
        O.append(lst)

    # model
    model = gp.Model()

    # silent/verbose mode
    model.Params.OutputFlag = 0 
    
    # variables
    if method == "mip":
        x = model.addVars(A0,vtype=gp.GRB.BINARY,name="x")
    else:
        x = model.addVars(A0,lb=0.0,ub=1.0,vtype=gp.GRB.CONTINUOUS,name="x")
    
    #objective
    obj = 0
    for e in A0:
        obj += 1*x[e]
         
    model.setObjective(obj,gp.GRB.MAXIMIZE)

    # constraints
    for j in nodes:
        constr = 0
        for i in O[j]:
            constr += x[(i,j)] 
        model.addConstr(constr <= 1.0,"constr2")

    constr = 0
    for i in nodes:
        constr += x[(i,i)] 
    model.addConstr(constr <= 2.0,"constr3")

    for e in A:
        model.addConstr(x[(e[0],e[1])] <= x[(e[0],e[0])],"constr4")

    for e in EN:
        for p in O[e[0]]:
            if p in O[e[1]]:
                model.addConstr(x[(p,e[0])] + x[(p,e[1])] <= x[(p,p)],"constr5")

    #for e in EP:
    #    for p in O[e[0]]:
    #        M = list(set(O[e[1]]) - {p})
    #        for q in M:
    #            model.addConstr(x[(p,e[0])] + x[(q,e[1])] <= 1.0,"constr6")

    # ineq of lemma 3.5
    for e in EP:
        S = O[e[0]]
        M = O[e[1]]
        constr0 = 0
        for p in S:
            constr0 += x[(p,e[0])]
        constr1 = 0
        for p in list(set(M) - set(S)):
            constr1 += x[(p,e[1])]
        model.addConstr(constr0 + constr1 <= 1.0, "constr9")

    # export .lp
    #model.write(instance+"_model.lp")

    # parameters 
    model.setParam(gp.GRB.Param.TimeLimit,3600.0)
    model.setParam(gp.GRB.Param.MIPGap,1.e-6)
    model.setParam(gp.GRB.Param.Threads,1)
    #model.setParam(gp.GRB.Param.Cuts,-1)
    #model.setParam(gp.GRB.Param.Presolve,-1)

    # optimize
    model.optimize()
        
    tmp = 0
    if model.status == gp.GRB.OPTIMAL:
        tmp = 1
 
    objval = model.objVal
    if method == "mip":
        objbound = model.objBound 
        mipgap = model.MIPGap
        nodecount = model.NodeCount
    runtime = model.Runtime
    status = tmp
        
    # export solution
    if method == "mip":
        arq = open(os.path.join(results_path,f'{method}_n{n}_signed_graphs_ineq9.txt'),'a')
        arq.write(instance+';'
        +str(round(objval,2))+';'
        +str(round(objbound,2))+';'
        +str(round(mipgap,2))+';'
        +str(round(runtime,2))+';'
        +str(round(nodecount,2))+';'
        +str(round(tmp,2))+'\n')
    else:
        arq = open(os.path.join(results_path,f'{method}_n{n}_signed_graphs_ineq9.txt'),'a')
        arq.write(instance+';'
        +str(round(objval,2))+';'
        +str(round(runtime,2))+'\n')
	
    arq.close()
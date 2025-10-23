#!/bin/bash

form_=edge 
inst_="data/kmbs/instances/RANDOM/random_n20_k2_pos30_neg5_err5_1.g"
method_="mip"
k=2

julia ksignedge.jl --inst ${inst_} --form ${form_} --numbk ${k}

mv saida.txt result/

#for n in 60
#do
#    for k in 2 3 4 5 
#    do
#        for pos in 30
#        do
#            for neg in 5
#            do
#                for err in 5 10 20
#                do
#                    for id in 1 2 3 4 5
#                    do
#                        julia ksigned.jl --inst data/kmbs/instances/RANDOM/random_n${n}_k${k}_pos${pos}_neg${neg}_err${err}_${id}.g --form ${form_} --numbk ${k} >> report/out_random_n${n}_k${k}_pos${pos}_neg${neg}_err${err}_${id}.txt
#                    done
#                done
#            done
#        done
#         mv saida.txt result/random_n${n}_k${k}.txt
#    done
#done

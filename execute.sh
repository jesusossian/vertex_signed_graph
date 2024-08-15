#!/bin/bash

method="lp"

for n in 60
do
    for k in 2 3 4 5 
    do
        for pos in 30
        do
            for neg in 5
            do
                for err in 5 10 20
                do
                    for id in 1 2 3 4 5
                    do
                        python3 src/main.py ${method} random_n${n}_k${k}_pos${pos}_neg${neg}_err${err}_${id}.g >> /home/jossian/Downloads/develop/report/signed_graphs/out_${method}_random_n${n}_k${k}_pos${pos}_neg${neg}_err${err}_${id}.txt
                    done
                done
            done
        done
    done
done

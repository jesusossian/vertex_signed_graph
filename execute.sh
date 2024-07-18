#!/bin/bash

for n in 60
do
    for k in 2
    do
        for pos in 30
        do
            for neg in 5
            do
                for err in 5
                do
                    for id in 3
                    do
                        python3 src/main.py random_n${n}_k${k}_pos${pos}_neg${neg}_err${err}_${id}.g >> /home/jossian/Downloads/develop/report/signed_graphs/out_random_n${n}_k${k}_pos${pos}_neg${neg}_err${err}_${id}.txt
                    done
                done
            done
        done
    done
done

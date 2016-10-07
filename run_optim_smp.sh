#!/bin/sh
#BSUB -a openmp
#BSUB -q fat
#BSUB -W 48:00
#BSUB -o RUN-%J.smp.out
#BSUB -n 25
#BSUB -R span[hosts=1]

Rscript --slave "run_optim_smp.R"

#!/bin/sh
#BSUB -a openmp
#BSUB -q fat
#BSUB -W 48:00
#BSUB -o RUN-%J.smp.out
#BSUB -n 64
#BSUB -R span[hosts=1]
#BSUB -R np64

Rscript --slave "run_optim_smp.R"

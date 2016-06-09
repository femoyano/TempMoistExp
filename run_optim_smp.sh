#!/bin/sh
#BSUB -a openmp
#BSUB -q fat
#BSUB -W 48:00
#BSUB -o RUN-%J.smp.out
#BSUB -n 64
#BSUB -R span[hosts=1]
#BSUB -R np64

module load intel/mkl/64/11.2/2015.3.187

Rscript --slave "run_optim_smp.R"

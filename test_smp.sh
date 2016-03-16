#!/bin/sh
#BSUB -a openmp
#BSUB -q fat-short
#BSUB -W 00:05
#BSUB -n 20
#BSUB -o out.optim.%J
#BSUB -R span[hosts=1]

module load intel/mkl/64/11.2/2015.3.187

Rscript --slave "test_smp.R"

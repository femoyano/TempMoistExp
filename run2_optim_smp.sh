#!/bin/sh
#BSUB -a openmp
#BSUB -q fat
#BSUB -W 6:00
#BSUB -o %J.out.smp
#BSUB -n 64
#BSUB -R span[hosts=1]
#BSUB -R np64

module load intel/mkl/64/11.2/2015.3.187

Rscript --slave "optim_run_smp_2.R"

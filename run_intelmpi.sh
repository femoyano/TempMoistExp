#!/bin/sh
#BSUB -a intelmpi
#BSUB -q mpi
#BSUB -W 3:00
#BSUB -n 128
#BSUB -o %J.out.mpi

module load intel/mkl/64/11.2 && module load intel-mpi

mpirun.lsf Rscript --slave "optim_run_mpi.R"


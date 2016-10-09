#!/bin/sh
#BSUB -a openmpi
#BSUB -q mpi
#BSUB -W 48:00
#BSUB -n 500,1000
#BSUB -o out.%J.mpi.out

module load intel/mkl/64 && module load openmpi/gcc

mpirun.lsf Rscript --slave "run_mpi.R"

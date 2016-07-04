#!/bin/sh
#BSUB -a openmpi
#BSUB -q mpi
#BSUB -W 12:00
#BSUB -n 101,110
#BSUB -o out.%J.mpi.out

module load intel/mkl/64/11.2/2015.3.187 && module load openmpi/intel

mpirun.lsf Rscript --slave "run_mpi.R"

#!/bin/sh
#BSUB -a openmpi
#BSUB -q mpi
#BSUB -W 4:00
#BSUB -n 80
#BSUB -o %J.out.mpi

module load intel/mkl/64/11.2/2015.3.187 && module load openmpi/intel

mpirun.lsf Rscript --slave "optim_run_mpi.R"

#!/bin/sh
#BSUB -a openmpi
#BSUB -q mpi
#BSUB -W 00:05
#BSUB -n 10
#BSUB -o out.%J.test.smp

module load intel/mkl/64/11.2/2015.3.187 && module load openmpi/intel

mpirun.lsf Rscript --slave "test_mpi.R"

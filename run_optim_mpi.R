#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as distributed memory job (MPI)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================


### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###

# Setup
setup <- list(
  # -------- Model options ----------
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 0 ,  # simulate microbial pool explicitly
  flag.fcs  = 0 ,  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  dce.fun  = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun = "cubic" ,  # Options: 'hama', 'cubic'
  
  # -------- Calibration options ----------
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  "rate.sd", "rate.mean"...
  cost.type = "rate.sd" ,
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_4s.csv" ,
  # Set of parameters initial values and bounds. Names must have: 
  # -nb/-wb (narrow bounds or wide bounds), -mic/-nomic, -min/-nomin, -v1/-v2/...
  pars_optim = "-nb-nomic-nomin-v1" ,
  # Choose method for modFit
  mf.method = "Pseudo"
)

### ----------------------------------- ###
###    Setings for parallel processing  ###
### ----------------------------------- ###
library(doMPI)
cl <- startMPIcluster()
registerDoMPI(cl)
cores <- clusterSize(cl)

source("optim_main.R")

closeCluster(cl)
mpi.quit()

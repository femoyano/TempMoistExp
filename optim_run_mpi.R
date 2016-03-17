#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as distributed memory job (MPI)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================


### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###

# Model flags and other options
setup <- list(
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 0 ,  # simulate microbial pool explicitly
  flag.fcs  = 1 ,  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  = 1 ,  # calculate C_E and C_D concentration in water
  flag.des  = 0 ,  # run using differential equation solver? If TRUE then t_step has no effect.
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.dcf  = 0 ,  # diffusivity carbon function: 0 = exponential, 1 = linear
  
  t_step     = "hour"  ,  # Model time step (as string). Important when using stepwise run.
  t_save     = "hour"  ,  # save time step (only for stepwise model?)
  ode.method = "lsoda" ,  # see ode function
  
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  "rate.sd", "rate.mean"...
  cost.type = "rate.sd" ,
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_smp.csv" ,
  pars_optim_file = "pars_optim_values_2.R"
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

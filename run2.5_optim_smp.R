#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

t0 <- Sys.time()

### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###
runname <- "RUNOPT2.5"

# Model flags and other options
setup <- list(
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 0 ,  # simulate microbial pool explicitly
  flag.fcs  = 0 ,  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
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
  # Set of parameters initial values and bounds: set1, set2, ...
  pars_optim = "set2"
)


### ----------------------------------- ###
###    Setings for parallel processing  ###
### ----------------------------------- ###
library(doParallel)
cores = detectCores()
cat("Cores detected:", cores, "\n")
registerDoParallel(cores = cores)


### ----------------------------------- ###
###         Run optimization            ###
### ----------------------------------- ###
source("optim_main.R")

print(Sys.time() - t0)


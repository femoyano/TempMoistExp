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

# Setup
setup <- list(
  # -------- Model options ----------
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 1 ,  # simulate microbial pool explicitly
  flag.fcs  = 1 ,  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  = 1 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 1 ,  # diffusivity temperature effect on/off
  flag.dce  = 1 ,  # diffusivity carbon effect on/off
  dce.fun  = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun = "cubic" ,  # Options: 'hama', 'cubic'
  
  # -------- Calibration options ----------
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  "rate.sd", "rate.mean"...
  cost.type = "rate.sd" ,
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_4s.csv" ,
  # Set of parameters initial values and bounds. Names can have: 
  # -nb (narrow bounds), -wb (wide bounds), -mic, -nomic, -min, -nomin, -v1, -v2, etc.
  pars_optim = "-nb-nomic-nomin-v1"
)


### ----------------------------------- ###
###    Setings for parallel processing  ###
### ----------------------------------- ###
library(doParallel)
cores = detectCores()
# cores = 1
cat("Cores detected:", cores, "\n")
registerDoParallel(cores = cores)


### ----------------------------------- ###
###         Run optimization            ###
### ----------------------------------- ###
source("optim_main.R")

print(Sys.time() - t0)


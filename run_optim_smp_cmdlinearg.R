#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### ----------------------------------- ###
###    Setings for parallel processing  ###
### ----------------------------------- ###
library(doParallel)
cores = detectCores()
# cores = 1
cat("Cores detected:", cores, "\n")
registerDoParallel(cores = cores)


t0 <- Sys.time()


### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###

setup <- list(
  RunInfo = "Description of this run",
  
  # -------- Model options ----------
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 1 ,  # simulate microbial pool explicitly
  flag.fcs  = 1 ,  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.mmu  = 1 ,  # michalis menten kinetics for uptake, else equal diffusion flux
  flag.mmr  = 1 ,  # microbial maintenance respiration
  dce.fun  = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun = "hama" ,  # Options: 'hama', 'cubic'
  
  # -------- Calibration options ----------
  run.test  = 0 ,  # run model cost once as test?
  run.sens  = 0 ,  # run FME sensitivity analysis?
  run.mfit  = 1 ,  # run modFit for optimization?
  run.mcmc  = 1 ,  # run Markov Chain Monte Carlo?
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  "rate.sd", "rate.mean"...
  SRerror = NULL ,
  TRerror = NULL ,
  SRweight = 'std' ,
  TRweight = 'std' ,
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_smp.csv" ,
  # Choose method for modFit
  mf.method = "Nelder-Mead" ,
  cost.fun = "ModCost_SR_TR.R" ,
  
  # -------- Parameter options ----------
  # csv file with default parameters
  pars.default.file = "../parsets/parset6-dev2-3_all.csv" ,
  # csv file with bounds for optimized parameters
  pars.bounds.file = "../parsets/pars_bounds_v1.csv"
)


### ----------------------------------- ###
###        Setting up parameters        ###
### ----------------------------------- ###

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose initial valeus for optimized parameters
runind <- as.integer(commandArgs(trailingOnly = TRUE))
pars.mult.file   <- "../parsets/parset_selection.csv"
pars_calib <- as.matrix(read.csv(pars.mult.file))
pars.optim.file <- paste0("../parsets/parset_temp", runind, ".csv")
write.csv(pars_calib[runind, ], file = pars.optim.file)


### ----------------------------------- ###
###      Run multiple optimizations     ###
### ----------------------------------- ###
runname <- paste("MultRun", runind, sep="")
cat("Starting run number", runind, "\n")
source("main_optim.R")

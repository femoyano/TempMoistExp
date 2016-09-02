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
  RunInfo = "Description of this run",
  
  # -------- Model options ----------
  flag.mic  = 1 ,  # simulate microbial pool explicitly
  flag.fcs  = 1 ,  # scale C_P and M to field capacity (with max at fc)
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.mmu  = 1 ,  # michalis menten kinetics for uptake, else equal diffusion flux
  flag.mmr  = 1 ,  # microbial maintenance respiration
  dce.fun   = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun  = "hama" ,  # Options: 'hama', 'cubic'
  
  # -------- Calibration options ----------
  run.test  = 0 ,  # run model cost once as test?
  run.sens  = 0 ,  # run FME sensitivity analysis?
  run.mfit  = 0 ,  # run modFit for optimization?
  run.mcmc  = 1 ,  # run Markov Chain Monte Carlo?
  # Observation error: name of column with error values ('sd' or 'uw'). NULL to use weight.
  SRerror  = 'C_R_sd'  ,
  TRerror  = NULL  ,
  # Weight for cost:  only if error is NULL. One of 'none', 'mean', 'std'.
  SRweight = 'none' ,
  TRweight = 'none' ,
  # Scale variables? TRUE or FALSE
  scalevar = TRUE  ,
  # Choose method for modFit
  mf.method = "Nelder-Mead"     ,
  # Choose cost function
  cost.fun  = "ModCost_SR.R" ,
  # Choose MCMC options:
  niter  = 1,  # number of iterations
  jfrac  = 200  ,  # fraction of parameters size for jumps
  burnin = 0 ,  # length of burn in
  udcov  = 500  ,  # iteration period for updating covariance matrix 
  
  # -------- Parameter options ----------
  # csv file with default parameters
  pars.default.file = "parsets/parset6-6noAC_all.csv" ,
  # csv file with initial valeus for optimized parameters
  pars.optim.file   = "parsets/parset6_noAC.csv"     ,
  # csv file with bounds for optimized parameters
  pars.bounds.file  = "parsets/pars_bounds_v1.csv"
)


### ----------------------------------- ###
###   Settings for parallel processing  ###
### ----------------------------------- ###
library(doParallel)
cores = detectCores()
# cores = 1
cat("Cores detected:", cores, "\n")
registerDoParallel(cores = cores)


### ----------------------------------- ###
###         Run optimization            ###
### ----------------------------------- ###
source("main_optim.R")

print(Sys.time() - t0)


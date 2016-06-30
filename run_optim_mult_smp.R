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
# Setup
setup <- list(
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
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  "rate.sd", "rate.mean"...
  cost.type = "rate.mean" ,
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_smp.csv" ,
  # Choose method for modFit
  mf.method = "Nelder-Mead"
)


### ----------------------------------- ###
###        Setting up parameters        ###
### ----------------------------------- ###

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose default parameters
pars.default.file <- "parset6.csv"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose initial valeus for optimized parameters
pars.calib.file   <- "pars_calib_lh10.csv"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose bounds R file
pars.bounds.file <- "pars_bounds_v1.R"

pars <- as.matrix(read.csv(pars.default.file))[1,]
pars_calib <- as.matrix(read.csv(file=pars.calib.file))
source(pars.bounds.file)
pars_optim_lower <- pars_bounds[1,]
pars_optim_upper <- pars_bounds[2,]


### ----------------------------------- ###
###      Run multiple optimizations     ###
### ----------------------------------- ###
runind <- as.integer(commandArgs(trailingOnly = TRUE))
runname <- paste("MultRun", runind, sep="")
pars_optim_init <- pars_calib[runind, ]
cat("Starting run number", runind, "\n")
source("optim_main.R")

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
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.mmu  = 1 ,  # michalis menten kinetics for uptake, else equal diffusion flux
  flag.mmr  = 1 ,  # microbial maintenance respiration
  run.test  = 0 ,  # run model cost once as test?
  run.sens  = 0 ,  # run FME sensitivity analysis?
  run.mfit  = 1 ,  # run modFit for optimization?
  run.mcmc  = 0 ,  # run Markov Chain Monte Carlo?
  dce.fun  = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun = "hama" ,  # Options: 'hama', 'cubic'
  
  # -------- Calibration options ----------
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  "rate.sd", "rate.mean"...
  cost.type = "rate.mean" ,
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_smp.csv" ,
  # Choose method for modFit
  mf.method = "Nelder-Mead" ,
  cost.fun = "ModCost_TR.R"
)

### ----------------------------------- ###
###        Setting up parameters        ###
### ----------------------------------- ###

pars.path <- file.path('..', 'parsets')

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose default parameters (csv file)
pars.default.file <- '../parsets/parset6-dev2-3_all.csv'
pars <- read.csv(pars.default.file, row.names = 1)
pars <- setNames(pars[[1]], row.names(pars))


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose initial valeus for optimized parameters (csv file)
pars.optim.file <- '../parsets/parset6-dev2-3_all.csv'
pars_optim_init <- read.csv(pars.optim.file, row.names = 1)
pars_optim_init <- setNames(pars_optim_init[[1]], row.names(pars_optim_init))

# # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose bounds (R script file)
source("../parsets/pars_bounds_v1.R")
pars_optim_lower <- pars_bounds[1,]
pars_optim_upper <- pars_bounds[2,]

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
source("optim_main.R")

print(Sys.time() - t0)


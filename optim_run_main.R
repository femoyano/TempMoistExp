#### optim_run_main.R

#### Documentations ===========================================================
# Script used to prepare settings and run parameter optimization
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### Libraries =================================================================
require(deSolve)
require(FME)
require(plyr)
require(reshape2)

### Define time variables =====================================================
year     <- 31104000 # seconds in a year
hour     <- 3600     # seconds in an hour
sec      <- 1        # seconds in a second!
runtime  <- format(Sys.time(), "%y-%m-%d-%H-%M")

# Model flags and other options ----------------------------------------------------------
setup <- list(
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 0 ,  # simulate microbial pool explicitly
  flag.fcs  = 1 ,  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  = 1 ,  # calculate C_E and C_D concentration in water
  flag.des  = 1 ,  # run using differential equation solver? If TRUE then t_step has no effect.
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.dcf  = 0 ,  # diffusivity carbon function: 0 = exponential, 1 = linear
  
  t_step     = "hour"  ,  # Model time step (as string). Important when using stepwise run.
  t_save     = "hour"  ,  # save time step (only for stepwise model?)
  ode.method = "lsoda" ,  # see ode function
  
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  ...
  cost.type = "uwr" ,
  # Which samples to run?
  sample_list_file = "samples_smp.csv" , # e.g. samples.csv, samples_smp.csv, samples_test2.csv
  pars_optim_file = "pars_optim_values_3.R"
)

list2env(setup, envir = .GlobalEnv)

# Other settings
tstep <- get(t_step)
tsave <- get(t_save)
spinup     <- FALSE
eq.stop    <- FALSE   # Stop at equilibrium?

# Input Setup -----------------------------------------------------------------
data.samples  <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", sample_list_file))
input.all     <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "site_BareFallow42p.csv"))

obs.accum <- obs.accum[obs.accum$sample %in% data.samples$sample,]

### Sourced required files ----------------------------------------------------
source("parameters.R")
source(pars_optim_file)
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")
source("initial_state.R")
source("ModRes.R")
source("ModCost.R")
source("AccumCalc.R")
source("ParsReplace.R")
source("SampleRun.R")
source("SampleCost.R")
source("GetModelData.R")
source("ParSens.R")

### Check model cost and computation time --------------
# ptm0 <- proc.time()
# Resid <- ModRes(pars_optim_init)
# print(cat('t0',proc.time() - ptm0))

### Check sensitivity of parameters ---------------
# par_sens <- ParSens(ModCost, pars_optim_init)

## Optimize parameters
fitMod <- modFit(f = ModRes, p = pars_optim_init, method = "Nelder-Mead", upper = pars_optim_upper, lower = pars_optim_lower)
# Plot and get statistics
# source("analysis.R")

### Run Bayesian optimization
# var0 = fitMod$var_ms_unweighted

# # ACHTUNG! if var0 is NULL, cist function must return -1log(prob.model). See documentation.
# modMCMC(f=ModCost, p=fitMod$par, niter=5000, jump=NULL,  
#         var0=NULL, lower=low,
#         upper=up,burninlength = 5000)

### Save results
rm(list=names(setup), year, hour, sec, tstep, tsave, spinup, eq.stop, data.samples, input.all, site.data.bf, site.data.mz, initial_state)
save.image(file = paste("ModelCalib_", runtime, ".RData", sep = ""))

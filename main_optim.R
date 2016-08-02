#### Documentations ===========================================================
# Script used to prepare settings and run parameter optimization
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================


### ----------------------------------- ###
###      Non User Setup                 ###
### ----------------------------------- ###

### Libraries =================================================================

require(deSolve)
require(FME)
require(plyr)
require(reshape2)

### Extract setup variables ===================================================
list2env(setup, envir = .GlobalEnv)

### Define time variables =====================================================
year     <- 31104000 # seconds in a year
hour     <- 3600     # seconds in an hour
sec      <- 1        # seconds in a second!

# ----- fixed model setup ----
t_step     <- "hour"  # Model time step (as string). Important when using stepwise run.
t_save     <- "hour"  # save time step (only for stepwise model?)
ode.method <- "lsoda"  # see ode function
flag.des   <- 1       # Cannot be changed: model crashes when doing stepwise.
tstep      <- get(t_step)
tsave      <- get(t_save)
spinup     <- FALSE
eq.stop    <- FALSE   # Stop at equilibrium?
savename   <- paste("RunOpt", "-ads", flag.ads, "_mic", flag.mic, "_fcs", flag.fcs, "_sew", flag.sew,
                 "_dte", flag.dte, "_dce", flag.dce, "_", dce.fun, "_", diff.fun,
                 "_", mf.method, "_", cost.type, "-", sep = "")

### Sourced required files ====================================================
source("flux_functions.R")
source("Model_desolve.R")
source("initial_state.R")
source(cost.fun)
source("AccumCalc.R")
source("ParsReplace.R")
source("SampleRun.R")

# Parameter setup =============================================================
pars_default <- read.csv(pars.default.file, row.names = 1)
pars_default <- setNames(pars_default[[1]], row.names(pars_default))

pars_optim_init <- read.csv(pars.optim.file, row.names = 1)
pars_optim_init <- setNames(pars_optim_init[[1]], row.names(pars_optim_init))

pars_bounds <- read.csv(pars.bounds.file, row.names = 1)
pars_optim_lower <- setNames(pars_bounds[[1]], row.names(pars_bounds))
pars_optim_upper <- setNames(pars_bounds[[2]], row.names(pars_bounds))

# Input Setup =================================================================
input_path    <- file.path("..","input_data")
data.samples  <- read.csv(file.path(input_path, sample_list_file))
input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))

obs.accum <- obs.accum[obs.accum$sample %in% data.samples$sample,]


### ----------------------------------- ###
###      Optimization/Calibration       ###
### ----------------------------------- ###

# Test model cost and computation time --------------
if (run.test) system.time(cost <- ModCost(pars_optim_init))

### Check sensitivity of parameters ---------------
if(run.sens) Sfun <- sensFun(ModCost, pars_optim_init)

## Optimize parameters
if (run.mfit) {
  fitMod <- modFit(f = ModCost, p = pars_optim_init, method = mf.method, 
                   upper = pars_optim_upper, lower = pars_optim_lower)
  
  ## Saving work space
  savetime  <- format(Sys.time(), "%m%d-%H%M")
  save.image(file = paste(savename, savetime, ".RData", sep = ""))
}


## Run Bayesian optimization
if(run.mcmc) {
  # var0 = obs.accum$sd.r
  var0 <- summary(fitMod)$modVariance
  Covar <- summary(fitMod)$cov.scaled * 2.38^2/(length(fitMod$par))
  jump <- abs(fitMod$par/100)
  if(run.mfit) pars.mcmc <- fitMod$par else pars.mcmc <- pars
  mcmcMod <- modMCMC(f=ModCost, p=pars.mcmc, jump = jump, niter=5000, var0=var0,
                     lower=pars_optim_lower, upper=pars_optim_upper, 
                     updatecov = 100, burninlength = 0)
}

## Saving work space
savetime  <- format(Sys.time(), "%m%d-%H%M")
save.image(file = paste(savename, savetime, ".RData", sep = ""))

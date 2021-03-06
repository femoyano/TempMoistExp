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

starttime  <- format(Sys.time(), "%m%d-%H%M")

### Define time variables =====================================================
year     <- 31104000 # seconds in a year
hour     <- 3600     # seconds in an hour
sec      <- 1        # seconds in a second!

# ----- fixed model setup ----
t_step     <- "hour"  # Model time step (as string). Important when using stepwise run.
t_save     <- "hour"  # save time step (only for stepwise model?)
ode.method <- "lsoda"  # see ode function
flag_des   <- 1       # Cannot be changed: model crashes when doing stepwise.
tstep      <- get(t_step)
tsave      <- get(t_save)
spinup     <- FALSE
eq.stop    <- FALSE   # Stop at equilibrium?

### Sourced required files ====================================================
source("flux_functions.R")
source("Model.R")
source("initial_state.R")
source(cost_fun)
source("AccumCalc.R")
source("ParsReplace.R")
source("SampleRun.R")

# Parameter setup =============================================================
pars_default <- read.csv(pars.default.file, row.names = 1)
pars_default <- setNames(pars_default[[1]], row.names(pars_default))

pars_optim       <- read.csv(pars.optim.file, row.names = 1)
pars_optim_init  <- setNames(pars_optim[[1]], row.names(pars_optim))
pars_optim_lower <- setNames(pars_optim[[2]], row.names(pars_optim))
pars_optim_upper <- setNames(pars_optim[[3]], row.names(pars_optim))

# Input Setup =================================================================
input_path    <- file.path("..","input_data")
input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))

# Save text
savetxt2 <- paste0('_dec', dec_fun, '-upt', upt_fun, '-diff', diff_fun, '_')

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
}

## Saving work space
save.image(file = paste("Run_Optim_", starttime, savetxt, savetxt2, ".RData", sep = ""))

## Run Bayesian optimization
if(run.mcmc) {
  # var0 = obs.accum$sd.r
  if(run.mfit) {
    pars.mcmc <- fitMod$par
    var0 <- summary(fitMod)$modVariance
    # Covar <- summary(fitMod)$cov.scaled * 2.38^2/(length(fitMod$par)) # can use as jump
    } else {
      pars.mcmc <- pars_optim_init
      var0 <- 0.0025
    }
  jump <- abs(pars.mcmc/jfrac)
  mcmcMod <- modMCMC(f=ModCost, p=pars.mcmc, jump = jump, niter=niter, var0=var0,
                     lower=pars_optim_lower, upper=pars_optim_upper,
                     updatecov = udcov, burninlength = burnin)
## Saving work space
save(mcmcMod, file = paste("Run_mcmc_", starttime, savetxt, savetxt2, ".RData", sep = ""))
}


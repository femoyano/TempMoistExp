#### optim_run_main.R

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
runname <- paste("RUN", pars_optim, sep="")
options <- paste("-ads", flag.ads, "_mci", flag.mic, "_fcs", flag.fcs, "_sew", flag.sew,
                 "_dte", flag.dte, "_dce", flag.dce, "_", dce.fun, "_", diff.fun,
                 "_", mf.method, "_", cost.type, "-", sep = "")

# Input Setup -----------------------------------------------------------------
input_path    <- file.path(".")  # ("..", "Analysis", "NadiaTempMoist")
data.samples  <- read.csv(file.path(input_path, sample_list_file))
input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))

obs.accum <- obs.accum[obs.accum$sample %in% data.samples$sample,]

### Sourced required files ----------------------------------------------------
source("parameters.R")
source(paste("pars", pars_optim, ".R", sep = ""))
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")
source("initial_state.R")
# source("ModRes.R")
source("ModCost_byMoist.R")
source("AccumCalc.R")
source("ParsReplace.R")
source("SampleRun.R")
# source("SampleCost.R")
source("GetModelData.R")


### ----------------------------------- ###
###      Optimization/Calibration       ###
### ----------------------------------- ###

### Check model cost and computation time --------------
system.time(cost <- ModCost(pars_optim_init))

### Check sensitivity of parameters ---------------
Sfun <- sensFun(ModCost, pars_optim_init)
 
## Optimize parameters
fitMod <- modFit(f = ModCost, p = pars_optim_init, method = mf.method,
                 upper = pars_optim_upper, lower = pars_optim_lower)

savetime  <- format(Sys.time(), "%m%d-%H%M")

save.image(file = paste(runname, options, savetime, ".RData", sep = ""))

## Run Bayesian optimization
var0 = obs.accum$sd.r
 
mcmcMod <- modMCMC(f=ModCost, p=fitMod$par, niter=5000, var0=var0,
                   lower=pars_optim_lower, upper=pars_optim_upper)


### ----------------------------------- ###
###        Saving work space            ###
### ----------------------------------- ###

savetime  <- format(Sys.time(), "%m%d-%H%M")

rm(list=names(setup), year, hour, sec, tstep, tsave, spinup, eq.stop, input.all,
   site.data.bf, site.data.mz, initial_state, obs.accum)

save.image(file = paste(runname, options, savetime, ".RData", sep = ""))

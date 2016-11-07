#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

parind <- as.integer(commandArgs(trailingOnly = TRUE))

### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###
source('setup.R')
list2env(setup, envir = .GlobalEnv)

pars_default <- read.csv(pars.default.file, row.names = 1)
pars_default <- setNames(pars_default[[1]], row.names(pars_default))

pars_new <- as.matrix(read.csv(pars.mult.file))
pars_new <- pars_new[parind,]

source("ParsReplace.R")
pars <- ParsReplace(pars_new, pars_default)


# source("set_pars.R", local = TRUE)  # change specific par values  
# write.csv(pars, file = "../parsets/parset_new.csv", row.names = TRUE)  # Optional: save pars

### ----------------------------------- ###
###    Setings for parallel processing  ###
### ----------------------------------- ###
library(doParallel)
cores = detectCores()
# cores = 1
cat("Cores detected:", cores, "\n")
registerDoParallel(cores = cores)

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
runname <- "Run"
options <- paste("_mic", flag.mic, "_fcs", flag.mmu, "_mmu", flag.fcs, "_sew", flag.sew,
                 "_dte", flag.dte, "_dce", flag.dce, "_", dce.fun, "_", diff.fun,
                 "_", sep = "")

# Input Setup -----------------------------------------------------------------
input_path    <- file.path("..", "input_data")
input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))

### Sourced required files ----------------------------------------------------
source("flux_functions.R")
source("Model_desolve.R")
source("initial_state.R")
source("ModCost_SR.R")
source("AccumCalc.R")
source("SampleRun.R")
source("GetModelData.R")


### ----------------------------------- ###
###              Single Run             ###
### ----------------------------------- ###
t0 <- Sys.time()

mod.out <- foreach(i = unique(input.all$treatment), .combine = 'rbind', 
                   .export = c(ls(envir = .GlobalEnv), "pars"),
                   .packages = c("deSolve")) %dopar% {
                     SampleRun(pars, input.all[input.all$treatment==i, ])
                   }

print(Sys.time() - t0)


# ### ----------------------------------- ###
# ###        Analysis and Plotting        ###
# ### ----------------------------------- ###

source("post_process_fits.R")


# ### ----------------------------------- ###
# ###        Saving work space            ###
# ### ----------------------------------- ###
# 
# savetime  <- format(Sys.time(), "%m%d-%H%M")
# 
# rm(list=names(setup), year, hour, sec, tstep, tsave, spinup, eq.stop, input.all,
#    site.data.bf, site.data.mz, initial_state, obs.accum)
# 
# save.image(file = paste(runname, options, savetime, ".RData", sep = ""))




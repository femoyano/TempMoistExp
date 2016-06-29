#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================


### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###

# Setup
setup <- list(
  # -------- Model options ----------
  flag.ads  = 0 ,  # simulate adsorption desorption
  flag.mic  = 1 ,  # simulate microbial pool explicitly
  flag.fcs  = 1 ,  # scale C_P, C_A, M to field capacity (with max at fc)
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.mmu  = 1 ,  # michalis menten kinetics for uptake, else equal diffusion flux
  flag.mmr  = 1 ,  # microbial maintenance respiration
  dce.fun  = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun = "hama" ,  # Options: 'hama', 'cubic'
  
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file = "samples_smp.csv"
)


### ----------------------------------- ###
###           Set parameters            ###
### ----------------------------------- ###
# source("parameters.R")  # load default set (e.g. values from literature)
# pars_new <- pars  # Choose a par set
# source("ParsReplace.R")
# pars <- ParsReplace(pars_new, pars) # Replace the default values

load("../NadiaTempMoist/parsets/parset6.Rdata")  # Optional: load other par sets
source("set_pars.R", local = TRUE)  # change specific par values  
save(pars, file = "../NadiaTempMoist/parsets/parset.Rdata")  # Optional: save pars


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
runname <- paste("RUN_", sep="")
options <- paste("-ads", flag.ads, "_mic", flag.mic, "_fcs", flag.mmu, "_mmu", flag.fcs, "_sew", flag.sew,
                 "_dte", flag.dte, "_dce", flag.dce, "_", dce.fun, "_", diff.fun,
                 "_", sep = "")

# Input Setup -----------------------------------------------------------------
input_path    <- file.path(".")  # ("..", "NadiaTempMoist")
data.samples  <- read.csv(file.path(input_path, sample_list_file))
input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))

obs.accum <- obs.accum[obs.accum$sample %in% data.samples$sample,]

### Sourced required files ----------------------------------------------------
source("flux_functions.R")
source("Model_desolve.R")
source("initial_state.R")
source("ModCost_byMoist.R")
source("AccumCalc.R")
source("SampleRun.R")
source("GetModelData.R")


### ----------------------------------- ###
###              Single Run             ###
### ----------------------------------- ###
t0 <- Sys.time()



mod.out <- foreach(i = data.samples$sample, .combine = 'rbind',
                   .export = c(ls(envir = .GlobalEnv), "pars"),
                   .packages = c("deSolve")) %dopar% {
                     SampleRun(pars, data.samples[data.samples$sample==i, ],
                               input.all[input.all$sample==i, ])
                   }

print(Sys.time() - t0)


# ### ----------------------------------- ###
# ###        Analysis and Plotting        ###
# ### ----------------------------------- ###

source("analysis.R")

source("analysis_plots.R")


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




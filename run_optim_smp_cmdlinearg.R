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
###        Setting up parameters        ###
### ----------------------------------- ###

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose initial valeus for optimized parameters
runind <- as.integer(commandArgs(trailingOnly = TRUE))
pars.mult.file   <- "parsets/pars_lhs100000_top10.csv"
pars_calib <- as.matrix(read.csv(pars.mult.file))
pars.optim.file <- paste0("./parsets/parset_temp.csv")
write.csv(pars_calib[runind, ], file = pars.optim.file)

### ----------------------------------- ###
###       User Stup                     ###
### ----------------------------------- ###
source('setup.R')
list2env(setup, envir = .GlobalEnv)
savetxt <- paste(savetxt, "_multrun", runind, sep="")

### ----------------------------------- ###
###      Run multiple optimizations     ###
### ----------------------------------- ###
cat("Starting run number", runind, "\n")
source("main_optim.R")


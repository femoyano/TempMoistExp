#### Run_script

#### Documentations ===========================================================
# Script used to prepare settings and launch the model by calling main.R
# This file is the main user interface.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)

# Note: init.mode sets starting values of state variables for the transient run.
# init.mode can be either "spinup", "trans", "file" or "default";
# it gets values from: current spinup, current transient, init.file or initial_state.R, respectively
# Note that runs with same setup otpions will overwrite previous output files.
#### ==========================================================================

rm(list=ls()) # clear the work space

###############################################################################
### User Settings =============================================================
###############################################################################

### Required settings (will affect output) ====================================

# Model run type --------------------------------------------------------------
spin      <- 1  # set to TRUE to run spinup
trans     <- 0  # set to TRUE for a normal (transient) run

# Model flag options ----------------------------------------------------------
flag.ads  <- 1  # simulate adsorption desorption rates
flag.mic  <- 0  # simulate microbial pool explicitly
flag.fcs  <- 1  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
flag.sew  <- 1  # calculate C_E and C_D concentration in water
flag.des  <- 0  # run using differential equation solver? If TRUE then t_step has no effect.
flag.dte  <- 0  # diffusivity temperature effect on/off
flag.dce  <- 0  # diffusicity carbon effect on/off
flag.dcf  <- 0  # diffusicity carbon function: 0 = exponential, 1 = linear

# Input Setup -----------------------------------------------------------------
site.name      <- "Wetzstein"
init.file       <- "../Output/spinup_EDA_WetzsteinSM16.csv" # Used only if init.mode = "file".

# User Settings for Spinup Run ------------------------------------------------
spinup.data    <- "Wetzstein2007SM16"
spin.years     <- 50        # years for spinup run
t.save.spin    <- "month"   # interval at which to save output during spinup runs (as text).
init.mode.spin <- "default" # see note above
flag.cmi       <- 1         # use a constant mean input for spinup

# User Settings for Transient Run ---------------------------------------------
trans.data      <- "Wetzstein2007SM16"
t.save.trans    <- "day"    # interval at which to save output during transient runs (as text).
init.mode.trans <- "spinup" # see note above

### Optional Settings (may affect output values) ==============================

# model time unit
# Unit used for all rates (as string).
t_step      <- "hour"

# options related to differential equation solver
ode.method  <- "lsoda"  # see ode function

# stop at equilibrium options
eq.stop <- 0  # should a spinup run stop when soil C is close enough to equilibrium?
eq.md   <- 10 # equilibrium maximum difference allowed for C_P (in gC m-3 y-1)

### Input-output file and path names ==========================================

# input
input.path        <- file.path("..", "Input")
spinup.input.file <- file.path(input.path, paste("input_" , spinup.data, ".csv", sep=""))
trans.input.file  <- file.path(input.path, paste("input_" , trans.data , ".csv", sep=""))
site.file         <- file.path(input.path, paste("site_"  , site.name  , ".csv", sep=""))

# output
model.name        <- paste("SoilC-", "A", flag.ads, "_M", flag.mic, "_F", flag.fcs, 
                           "_S", flag.sew, "_D", flag.des, "_C", flag.cmi, sep = "")
spinup.name       <- paste("spinup", model.name, spinup.data, sep="_")
trans.name        <- paste("trans", model.name, trans.data, sep="_")
output.path       <- file.path("..", "Output")
spin.output.file  <- file.path(output.path, paste(spinup.name, ".csv", sep=""))
trans.output.file <- file.path(output.path, paste(trans.name, ".csv", sep=""))

###############################################################################
### Non User Settings =========================================================
###############################################################################

runscript <- TRUE # flag for main file
source("GetInitial.R")

### Spinup run ================================================================
if(spin) {
  spinup      <- TRUE # set spinup flag
  input.file  <- spinup.input.file
  run.name    <- spinup.name
  t_save      <- t.save.spin
  init.mode   <- init.mode.spin
  if(exists("initial_state")) rm(initial_state)
  if(init.mode == "spinup") init.file <- spin.output.file
  if(init.mode == "trans")  init.file <- trans.output.file
  if(init.mode == "default") source("initial_state.R") else {
    init <- tail(read.csv(init.file), 1)
    initial_state <- GetInitial(init)
  }
  source("main.R")
  out <- as.data.frame(out)
  out$C_R.rate <- c(0, diff(out$C_R))
  print(tail(out, 1))
  assign(spinup.name, out)
  write.csv(out, file = spin.output.file, row.names =  FALSE)
}

### Transient run =============================================================
if(trans) {
  spinup      <- FALSE      # unset spinup flag
  input.file  <- trans.input.file
  run.name    <- trans.name
  t_save      <- t.save.trans
  eq.stop     <- FALSE  # do not stop at equilibrium 
  init.mode <- init.mode.trans
  if(exists("initial_state")) rm(initial_state)
  if(init.mode == "spinup") init.file <- spin.output.file
  if(init.mode == "trans")  init.file <- trans.output.file
  if(init.mode == "default") source("initial_state.r") else {
    init <- tail(read.csv(init.file), 1)
    initial_state <- GetInitial(init) 
  }
  source("main.R")
  out <- as.data.frame(out)
  out$C_R.rate <- c(0, diff(out$C_R))
  assign(trans.name, out)
  write.csv(out, file = trans.output.file, row.names =  FALSE)
  print(tail(out, 1))
}

### Plot results ==============================================================
source("PlotResults.R")
if(spin) PlotResults(get(spinup.name), "month", path = file.path("..", "Output", "Plots", "Spinup"), spinup.name)
if(trans) PlotResults(get(trans.name), "day", path = file.path("..", "Output", "Plots", "Trans"), trans.name)

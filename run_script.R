### Run_script
rm(list=ls())

### User Settings - General =======================================================
spin           <- 1           # set to TRUE to run spinup
trans          <- 0           # set to TRUE for a normal (transient) run
site.name      <- "Wetzstein"

### User Settings for Spinup Run --------------------------------------------------
spinup.data    <- "Wetzstein2007SM16"
spin.years     <- 5   # maximum years for spinup runs
t.save.spin    <- "day"  # interval at which to save output during spinup runs (as text).

### User Settings for Transient Run ------------------------------------------------
init.mode      <- "spinup"
init.file      <- "../Output/spinup_EDA_WetzsteinSM16.csv" # Overwritten if init.mode = "spinup", "trans" or "default". 
trans.data     <- "WetzsteinSM16"
t.save.trans   <- "day"   # interval at which to save output during transient runs (as text).
# Note: init.mode sets starting values of state variables for the transient run.
# init.mode can be either "spinup", "trans", "file" or "default";
# it gets values from: current spinup, current transient, init.file or initial_state.r, respectively
# Note that runs with same setup will overwrite previous output files.

# Flags! -----------------------------------------------------------------------
flag.ads  <- 0  # model adsorption desorption rates?
flag.mic  <- 0  # model microbial pool explicitly?
flag.fcs  <- 1  # scale PC, SCs, ECs, M to field capacity (with max at fc)?
flag.sew  <- 1  # calculate EC and SC concentration in water?
flag.des  <- 0  # run using differential equation solver?
flag.cmi  <- 0  # use a constant mean input (e.g. for spinup)

### Optional Setup =============================================================
# input settings
input.path        <- file.path("..", "Input")
spinup.input.file <- file.path(input.path, paste("input_" , spinup.data, ".csv", sep=""))
trans.input.file  <- file.path(input.path, paste("input_" , trans.data , ".csv", sep=""))
site.file         <- file.path(input.path, paste("site_"  , site.name  , ".csv", sep=""))

# output settings
model.name        <- paste("SoilC-", "A", flag.ads, "_M", flag.mic, "_F", flag.fcs, "_P", flag.pcw, "_S", flag.sew, sep = "")
spinup.name       <- paste("spinup", model.name, spinup.data, sep="_")
trans.name        <- paste("trans", model.name, trans.data, sep="_")
output.path       <- file.path("..", "Output")
spin.output.file  <- file.path(output.path, paste(spinup.name, ".csv", sep=""))
trans.output.file <- file.path(output.path, paste(trans.name, ".csv", sep=""))

# Model time unit
# Unit used for all rates (as string). Must coincide with unit in input data
# Should not change results when using ode solver (test?)
t.unit      <- "hour"

ode.method  <- "lsoda"  # see ode function

### Non User Setup =============================================================
runscript <- TRUE # flag for main file
source("GetInitial.r")

### Spinup run =================================================================
if(spin) {
  spinup      <- TRUE # set spinup flag
  input.file  <- spinup.input.file
  run.name    <- spinup.name
  source("initial_state.r") # Loads initial state variable values
  source("main.R")
  print(tail(out, 1))
  assign(spinup.name, out)
  write.csv(out, file = spin.output.file, row.names =  FALSE)
}

### Transient run ==============================================================
if(trans) {
  spinup      <- FALSE      # unset spinup flag
  input.file  <- trans.input.file
  run.name    <- trans.name
  eq.stop     <- FALSE  # do not stop at equilibrium 
  if(exists("initial_state")) rm(initial_state)
  if(init.mode == "spinup") init.file <- spin.output.file
  if(init.mode == "trans") init.file <- trans.output.file
  if(init.mode == "default") source("initial_state.r") else {
    init <- tail(read.csv(init.file), 1)
    initial_state <- GetInitial(init) 
  }
  source("main.R")
  assign(trans.name, out)
  write.csv(out, file = trans.output.file, row.names =  FALSE)
  print(tail(out, 1))
}

# Plot results
source("PlotResults.R")
if(spin) PlotResults(get(spinup.name), "month", path = file.path("..", "Output", "Plots", "Spinup"), spinup.name)
if(trans) PlotResults(get(trans.name), "day", path = file.path("..", "Output", "Plots", "Trans"), trans.name)

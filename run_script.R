### Run_script
rm(list=ls())

### User Setup =================================================================
spin <- 1
trans <- 0
model.name  <- "EDA-desolve"
site.name   <- "Wetzstein"
spinup.data <- "WetzsteinSM16"
trans.data  <- "WetzsteinSM16"

## Getting starting values of state variables for the transient run.
# init.mode can be either "spinup", "trans", "file" or "default";
# it gets values from: current spinup, current transient, init.file or initial.state.r, respectively
# note that runs with same setup will overwrite previous output files
init.mode   <- "spinup"
init.file   <- "../Output/spinup_EDA_WetzsteinSM16.csv" # Overwritten if init.mode = "spinup", "trans" or "default". 

spin.years     <- 5000    # maximum years for spinup runs
t.save.spin    <- "year"  # interval at which to save output during spinup runs (as text).
t.save.trans   <- "day"   # interval at which to save output during transient runs (as text).
eq.stop.spinup <- FALSE   # Stop spinup at equilibrium?
eq.md          <- 20      # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.

# Flags! -----------------------------------------------------------------------
adsorption  <- 0  # should adsorption desortion rates be simulated?
microbes    <- 1  # should microbes be explicitly represented?
h2o.scale    <- 1  # should available pc scale with moisture (with max at fc)?
pc.conc     <- 1  # should available pc concentration change with moisture?
ec.conc     <- 1  # should SC concentration change with moisture?

### Optional Setup =============================================================
input.path        <- file.path("..", "Input")
output.path       <- file.path("..", "Output")
spinup.input.file <- file.path(input.path, paste("input_"     , spinup.data, ".csv", sep=""))
trans.input.file  <- file.path(input.path, paste("input_"     , trans.data , ".csv", sep=""))
site.file         <- file.path(input.path, paste("input_site_", site.name  , ".csv", sep=""))

spinup.name <- paste("spinup", model.name, spinup.data, sep="_")
trans.name  <- paste("trans", model.name, trans.data, sep="_")

t.unit      <- "hour" # Unit used for all rates (as string). Should not change results when using ode solver (test?)

### Non User Setup =============================================================
runscript <- TRUE # flag for main file
source("GetInitial.r")

### Spinup run =================================================================
if(spin) {
  spinup      <- TRUE # set spinup flag
  input.file  <- spinup.input.file
  spin.output.file <- file.path(output.path, paste(spinup.name, ".csv", sep=""))
  run.name    <- spinup.name
  eq.stop     <- eq.stop.spinup
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
  output.file <- file.path(output.path, paste(trans.name, ".csv", sep=""))
  run.name    <- trans.name
  eq.stop     <- FALSE  # do not stop at equilibrium 
  if(exists("initial_state")) rm(initial_state)
  if(init.mode == "spinup") init.file <- spin.output.file
  if(trans.init == "trans") init.file <- output.file
  if(init.mode == "default") source("initial_state.r") else {
    init <- tail(read.csv(init.file), 1)
    initial_state <- GetInitial(init) 
  }
  source("main.R")
  assign(trans.name, out)
  write.csv(out, file = output.file, row.names =  FALSE)
  print(tail(out, 1))
}

# Plot results
source("PlotResults.R")
if(spin) PlotResults(get(spinup.name), "year", path = "../Plots/Spinup/", spinup.name)
if(trans) PlotResults(get(trans.name), "day", path = "../Plots/Trans/", trans.name)

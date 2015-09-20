### Run_script
rm(list=ls())

### User Setup =================================================================
spin <- 1
trans <- 0
model.name  <- "EDA"
site.name   <- "Wetzstein"
spinup.data <- "WetzsteinSM16"
trans.data  <- "WetzsteinSM16"

t.max.spin     <- 300000    # maximum run time for spinup runs (in t_step units)
t_save_spinup  <- "day"    # time interval at which to save spinup output. Same or larger than t_step.
t_save_trans   <- "hour"    # time unit at which to save output. Cannot be less than t_step
eq.stop.spinup <- FALSE     # Stop spinup at equilibrium?
eq.md          <- 20        # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.

# Flags!
adsorption <- 0
enzyme.diff <- 1

### Optional Setup =============================================================
input.path        <- file.path("..", "Input")
output.path       <- file.path("..", "Output")
spinup.input.file <- file.path(input.path, paste("input_", spinup.data, ".csv", sep=""))
trans.input.file  <- file.path(input.path, paste("input_", trans.data, ".csv", sep=""))
site.file         <- file.path(input.path, paste("input_site_", site.name, ".csv", sep=""))

spinup.name <- paste("spinup", model.name, spinup.data, sep="_")
trans.name  <- paste("trans", model.name, trans.data, sep="_")

### Non User Setup =============================================================
runscript <- TRUE # flag for the main file
source("GetInitial.r")

### Spinup run =================================================================
if(spin) {
  input.file  <- spinup.input.file
  spin.output.file <- file.path(output.path, paste(spinup.name, ".csv", sep=""))
  run.name    <- spinup.name
  spinup      <- TRUE      # If TRUE then spinup run and data will be recylced.
  eq.stop     <- eq.stop.spinup
  t_step      <- "hour" # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- t_save_spinup
  source("initial_state.r") # Loads initial state variable values
  source("main.R")
  print(tail(out, 1))
  assign(spinup.name, out)
  write.csv(out, file = spin.output.file, row.names =  FALSE)
}

### Transient run ==============================================================
if(trans) {
  input.file  <- trans.input.file
  output.file <- file.path(output.path, paste(trans.name, ".csv", sep=""))
  run.name    <- trans.name
  spinup      <- FALSE      # If TRUE then spinup run and data will be recylced.
  t_step      <- "hour"     # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- t_save_trans
  eq.stop     <- FALSE       # Stop at equilibrium?
  if(exists("initial_state")) rm(initial_state)
  init <- tail(read.csv(spin.output.file), 1)
  initial_state <- GetInitial(init) 
  source("main.R")
  assign(trans.name, out)
  write.csv(out, file = output.file, row.names =  FALSE)
  print(tail(out, 1))
}

# Plot results
source("PlotResults.R")
if(spin) PlotResults(get(spinup.name), "month", path = "../Plots/Spinup/", spinup.name)
if(trans) PlotResults(get(trans.name), "day", path = "../Plots/Trans/", trans.name)

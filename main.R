#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

### Setup ======================================================================
rm(list=ls())

eq.run <- TRUE # Run to equilibrium? This will recycle input data.
eq.mpd <- 0.1 # equilibrium maximum percent difference. spinup run stops if difference is lower.
eq.max.time <- 20000

### Define time units ==========================================================
# (Warning! input data rates should have same time units as tunit)
day   <- 86400 # seconds in a day
hour  <- 3600  # seconds in an hour
sec   <- 1     # seconds in a second!
tunit <- day   # Notice: C inputs have to be in the same time units as the model tunit variable

### Libraries ====
# require(deSolve)

# Load input data
source("load_inputs.R")

# Sourced files
source("flux_functions.r")
source("model_parameters.r")
source("initial_state.r")          # Loads initial state variable values
source("ModelFull.R")

# Define model times: start, end and delt (resolution)
start <- 1
end   <- ifelse(eq.run, eq.max.time, forcing.data$day[length(forcing.data$day)])
delt  <- 1

model.out <- ModelAWB(eq.run, start, end, delt, initial_state, parameters, litter.data, forcing.data)


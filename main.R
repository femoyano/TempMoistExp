#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

# Processes simulated:
# - enzymatic decomposition
# - DOC and enzyme diffusion
# - microbial uptake and respiration
# - enzymatic production and breakdown
# - DOC and enzyme sorption to mineral surfaces
# - DOC flux to and from immobile zones

### Setup ======================================================================
rm(list=ls())

eq.run <- TRUE # Run to equilibrium? This will recycle input data.
eq.mpd <- 0.1 # equilibrium maximum percent difference. spinup run stops if difference is lower.

# Define time step (Warning! input data rates should have same time units as time step)
### Time values ====
day   <- 86400 # seconds in a day
hour  <- 3600  # seconds in an hour
sec   <- 1     # seconds in a second!
tunit <- day   # Notice: C inputs have to be in the same time units as the model tunit variable

# Libraries
# require(deSolve)

# Sourced files
source("flux_functions.r")
source("model_parameters.r")
source("initial_state.r")          # Loads initial state variable values
source("ModelRun.R")

### Inputs =====================================================================

# Load spatio_temporal input data
source("load_inputs.R")

# Define model times: start, end and delt (resolution)
start <- 1
end   <- ifelse(eq.run, 10000, forcing.data$day[length(forcing.data$day)])
delt  <- 1

model.out <- ModelRun(eq.run, start, end, delt, initial_state, parameters, litter.data, forcing.data)


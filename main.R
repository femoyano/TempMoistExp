#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

### Setup ======================================================================
rm(list=ls())

eq.run <- TRUE # Run to equilibrium? This will recycle input data.
eq.md  <- 0 # equilibrium maximum percent difference. spinup run stops if difference is lower.
eq.max.time <- 30000

t_unit <- "hour" # model time unit (as string): "hour", "day", "month" or "year"
delt   <-  1    # multiplier t_unit: defines model time step

### Define time units ==========================================================
# Warning! input data rates should have same time units as tunit
year  <- 31536000 # seconds in a year
month <- 2628000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
sec   <- 1        # seconds in a second!
tunit <- get(t_unit)      # hour, day, month or year (or fraction e.g. hour/2)


### Libraries ====
# require(deSolve)

# Load input data
source("load_inputs.R")

# Sourced files
source("flux_functions.r")
source("parameters.r")
source("initial_state.r")          # Loads initial state variable values
source("ModelMin.R")

# Define model times: start, end and delt (resolution)
start <- 1
end   <- ifelse(eq.run, eq.max.time, forcing.data$day[length(forcing.data[,1])])

model.out <- ModelMin(eq.run, start, end, delt, initial_state, parameters, litter.data, forcing.data)



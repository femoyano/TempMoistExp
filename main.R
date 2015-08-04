#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

### Setup ======================================================================
rm(list=ls())

spinup      <- TRUE    # Spinup run? Data will be recylced.
eq.stop     <- FALSE   # Stop at equilibrium?
eq.md       <- 1       # maximum difference for equilibrium conditions [in mgC gSoil-1]. spinup run stops if difference is lower.
t.max.spin  <- 500000  # maximum run time for spinup runs (in t_step units)
t_step      <- "hour"  # model time step (as string). Keep "hour" for correct equilibrium values
t_save      <- "day"  # time unit at which to save output. Cannot be less than t_step

## Flags =======================================================================

### Define time units ==========================================================
# Warning! input data rates should have same time units as tstep
year  <- 31104000 # seconds in a year
month <- 2592000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
sec   <- 1        # seconds in a second!
tstep <- get(t_step)      # model timestep: hour, day, month or year (or fraction e.g. hour/2)
tsave <- get(t_save)      # output save times: hour, day, month or year (or fraction e.g. hour/2)


### Libraries ====
# require(deSolve)

# Sourced files
source("parameters.r")
source("flux_functions.r")
source("CheckEquil.R")
source("initial_state.r")          # Loads initial state variable values
source("Model.R")

# Load input data
source("load_inputs.R")


## Debuging ====================================================================

# debugonce(F_sorp)

# Define model times: start and end
start <- ifelse(spinup, 1, forcing.data[1,1] )
end   <- ifelse(spinup, t.max.spin, tail(forcing.data[,1], 1) )

out <- Model(spinup, eq.stop, start, end, tstep, tsave, initial_state, parameters, litter.data, forcing.data)

print(tail(out, 1))

print(paste("Total soil C:", sum(tail(out, 1)[2:9])))

source("plot_results.R")

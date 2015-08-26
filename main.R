#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

### Setup if run script is not used ============================================
if(!exists("runscript")) {
  input.file  <- "input.csv"
  spinup      <- TRUE    # If TRUE then spinup run and data will be recylced.
  eq.stop     <- FALSE   # Stop at equilibrium?
  eq.md       <- 1       # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.
  t.max.spin  <- 100000  # maximum run time for spinup runs (in t_step units)
  t_step      <- "hour"  # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- "month" # time unit at which to save output. Cannot be less than t_step
  source("initial_state.r")
}

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
source("Model.R")

# Load input data
source("load_inputs.R")


## Debuging ====================================================================

# debugonce(F_sorp)

# Define model times: start and end
start <- ifelse(spinup, 1, input.data[1,1] )
end   <- ifelse(spinup, t.max.spin, tail(input.data[,1], 1) )

# Create model time step vector
times <- seq(start, end)
nt    <- length(times)

temp        <- input.data$temp       # [K] soil temperature
moist       <- input.data$moist      # [m3 m-3] specific soil volumetric moisture
litter_sc   <- input.data$litter_met # [mgC m^2] metabolic litter going to sc
litter_pc   <- input.data$litter_str # [mgC m^2] structural litter going to pc
times_input <- input.data[,1]        # time vector of input data

# Interpolate input variables
litter_pc <- approx(times_input, litter_pc, xout=times, rule=2)$y
litter_sc <- approx(times_input, litter_sc, xout=times, rule=2)$y
temp      <- approx(times_input, temp, xout=times, rule=2)$y
moist     <- approx(times_input, moist, xout=times, rule=2)$y

# If spinup, repeat input data
if(spinup) {
  temp  <- rep(temp, length.out = end)
  moist <- rep(moist, length.out = end)
  litter_pc <- rep(litter_pc,  length.out = end)
  litter_sc <- rep(litter_sc,  length.out = end)
}

out <- Model(spinup, eq.stop, start, end, tstep, tsave, initial_state, parameters, temp, moist, litter_pc, litter_sc)

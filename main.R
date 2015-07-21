#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

### Setup ======================================================================
# rm(list=ls())

spinup      <- TRUE    # Should data be recylced for spinup run?
eq.stop     <- FALSE   # Stop at equilibrium?
eq.md       <- 1       # maximum difference for equilibrium conditions [in mgC gSoil-1]. spinup run stops if difference is lower.
t.max.spin  <- 500000  # maximum run time for spinup runs
t_step      <- "hour"  # model time step (as string): "hour", "day", "month" or "year"
t_save      <- "year" # time unit at which to save output. Cannot be less than t_step


### Define time units ==========================================================
# Warning! input data rates should have same time units as tstep
year  <- 31536000 # seconds in a year
month <- 2628000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
sec   <- 1        # seconds in a second!
tstep <- get(t_step)      # model timestep: hour, day, month or year (or fraction e.g. hour/2)
tsave <- get(t_save)      # output save times: hour, day, month or year (or fraction e.g. hour/2)


### Libraries ====
# require(deSolve)

# Load input data
source("load_inputs.R")

# Sourced files
source("flux_functions.r")
source("CheckEquil.R")
source("parameters.r")
source("initial_state.r")          # Loads initial state variable values
source("Model.R")


# Define model times: start and end
start <- 1
end   <- ifelse(spinup, t.max.spin, forcing.data$day[length(forcing.data[,1])])

out <- Model(spinup, eq.stop, start, end, tsave, initial_state, parameters, litter.data, forcing.data)

# with(as.list(parameters), {
#   print( # steady state value for PC
#     -Em_ref * K_D_ref * (litter.data$litter_str[1] * (Mm_ref * (1 + CUE_ref * (mcpc_f - 1)) + E_p * (1 - CUE_ref)) + CUE_ref * litter.data$litter_met[1] * mcpc_f * Mm_ref) / 
#     (litter.data$litter_str[1] * (Mm_ref * (Em_ref * (1 + CUE_ref * (mcpc_f - 1))) + E_p * (Em_ref * (1 - CUE_ref) - CUE_ref * V_D_ref)) + CUE_ref * litter.data$litter_met[1] * (mcpc_f * Mm_ref * Em_ref - E_p * V_D_ref))
#   )
# })

tail(out, 1)

#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

### Setup ======================================================================
# rm(list=ls())

eq.run <- TRUE # Run to equilibrium? This will recycle input data.
eq.md       <- 2       # maximum difference for equilibrium conditions [in mgC gSoil-1]. spinup run stops if difference is lower.
eq.max.time <- 240000  # maximum run time for spinup runs
t_step      <- "hour"  # model time step (as string): "hour", "day", "month" or "year"
t_save      <- "month" # time unit at which to save results. Cannot be less than t_step


### Define time units ==========================================================
# Warning! input data rates should have same time units as tunit
year  <- 31536000 # seconds in a year
month <- 2628000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
sec   <- 1        # seconds in a second!
tunit <- get(t_step)      # hour, day, month or year (or fraction e.g. hour/2)
tsave <- get(t_save)


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
end   <- ifelse(eq.run, eq.max.time, forcing.data$day[length(forcing.data[,1])])

model.out <- Model(eq.run, start, end, tsave, initial_state, parameters, litter.data, forcing.data)

with(as.list(parameters), {
  print( # steady state value for PC
    -Em_ref * K_D_ref * (litter.data$litter_str[1] * (Mm_ref * (1 + CUE_ref * (mcpc_f - 1)) + E_p * (1 - CUE_ref)) + CUE_ref * litter.data$litter_met[1] * mcpc_f * Mm_ref) / 
    (litter.data$litter_str[1] * (Mm_ref * (Em_ref * (1 + CUE_ref * (mcpc_f - 1))) + E_p * (Em_ref * (1 - CUE_ref) - CUE_ref * V_D_ref)) + CUE_ref * litter.data$litter_met[1] * (mcpc_f * Mm_ref * Em_ref - E_p * V_D_ref))
  )
})
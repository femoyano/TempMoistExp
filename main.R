#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM-daily
# Time step: daily
# Note: C inputs have to be in the same time units as the model step

# Processes simulated:
# - enzymatic decomposition
# - DOC and enzyme diffusion
# - microbial uptake and respiration
# - enzymatic production and breakdown
# - DOC and enzyme sorption to mineral surfaces
# - DOC flux to and from immobile zones

### Setup ======================================================================

# Define time step (Warning! input data rates should have same time units as time step)
### Time values ====
day   <- 86400 # seconds in a day
hour  <- 3600  # seconds in an hour
sec   <- 1     # seconds in a second!
tstep <- day

# Libraries
require(deSolve)

# Sourced files
source("flux_functions.r")
source("temperature_functions.r")
source("model_parameters.r")
source("initial_state.r")          # Loads initial state variable values


### Inputs =====================================================================
  
# Load spatio_temporal input data
forcing.data  <- read.csv("forcing_data_daily.csv") # forcing data file
input_temp    <- forcing.data$temp   # [K] soil temperature
input_moist   <- forcing.data$moist  # [m^3 m^-3] soil volumetric water content
input_dmoist  <- forcing.data$dmoist # [m^3 m^-3] change in soil volumetric water content
times_forcing <- forcing.data$day    # time points when forcing is given

litter.data    <- read.csv("litter_input_daily.csv") # litter input rates file
input_litter_m <- litter.data$litter_m # [gC m^2] metabolic litter
input_litter_s <- litter.data$litter_s # [gC m^2] structural litter
times_litter   <- litter.data$day      # time points when litter is given

# Load spatial input data (texture data matrix)
# ... fixed in parameter list for now

# Define model time step vector
times <- seq(1,times_forcing[length(times_forcing)])

# Model definition ====
model.run <- function(times, state, parameters, input) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  with(as.list(c(state, parameters)),{
    
    # Interpolate input variables
    litter_m <- approx(times_litter, input_litter_m, xout=times, rule=2)$y
    litter_s <- approx(times_litter, input_litter_s, xout=times, rule=2)$y
    temp     <- approx(times_forcing, input_temp, xout=times, rule=2)$y
    theta    <- approx(times_forcing, input_moist, xout=times, rule=2)$y
    dtheta   <- approx(times_forcing, input_dmoist, xout=times, rule=2)$y
    
    # Calculate temporal values of T-dependent parameters
    K_LD <- Temp.Resp.Eq(K_LD_T0, temp, T0, E_K.LD, R)
    K_RD <- Temp.Resp.Eq(K_RD_T0, temp, T0, E_K.RD, R)
    K_SU <- Temp.Resp.Eq(K_SU_T0, temp, T0, E_K.SU, R)
    K_SS <- Temp.Resp.Eq(K_SS_T0, temp, T0, E_K.SS, R)
    K_ES <- Temp.Resp.Eq(K_ES_T0, temp, T0, E_K.ES, R)
    V_LD <- Temp.Resp.NonEq(V_LD_T0, temp, T0, E_V.LD, R)
    V_RD <- Temp.Resp.NonEq(V_RD_T0, temp, T0, E_V.RD, R)
    V_SU <- Temp.Resp.NonEq(V_SU_T0, temp, T0, E_V.SU, R)
    Mm   <- Mm_0 * exp(0.115 * (temp-273.15)) # Mm T dependency from Hagerty et al. 2014
    Em   <- Em_0 * exp(0.115 * (temp-273.15)) # Em T dependency (assumed equal to that of Mm, Hagerty et al. 2014)
    
    dLC  <- FluxLC()
    dRC  <- FluxRC()
    dSCw <- FluxSCw()
    dSCs <- FluxSCs()
    dSCd <- FluxSCm()
    dSCm <- FluxSCm()
    dECm <- FluxECm()
    dECw <- FluxECw()
    dECs <- FluxECs()
    dMC  <- FluxMC()
    
    list(c(dLC, dRC, dSCw, dSCs, dSCd, dSCm, dECw, dECs, dECm, dMC))
    
  }) # end of with...
} # end of model.run

out <- as.data.frame(ode(state, times, model.run, params))

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
times_forcing <- forcing.data$day    # time vector of the forcing data

litter.data    <- read.csv("litter_input_daily.csv") # litter input rates file
input_litter_m <- litter.data$litter_m # [gC m^2] metabolic litter
input_litter_s <- litter.data$litter_s # [gC m^2] structural litter
times_litter   <- litter.data$day      # time vector of the litter data

# Load spatial input data (texture data matrix)
# ... fixed in parameter list for now

# Define model time step vector
times <- seq(1,times_forcing[length(times_forcing)])

# Model definition ====
model.run <- function(times, state, parameters) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  with(as.list(c(state, parameters)),{
    
    # Interpolate input variables
    litter_m <- approx(times_litter, input_litter_m, xout=times, rule=2)$y
    litter_s <- approx(times_litter, input_litter_s, xout=times, rule=2)$y
    temp     <- approx(times_forcing, input_temp, xout=times, rule=2)$y
    theta    <- approx(times_forcing, input_moist, xout=times, rule=2)$y * depth
    dtheta   <- c(0,diff(theta))
    
    # Calculate temporal values of T-dependent parameters
    K_LD <- Temp.Resp.Eq(K_LD_T0, temp, T0, E_K.LD, R)
    K_RD <- Temp.Resp.Eq(K_RD_T0, temp, T0, E_K.RD, R)
    K_SU <- Temp.Resp.Eq(K_SU_T0, temp, T0, E_K.SU, R)
    K_SS <- Temp.Resp.Eq(K_SS_T0, temp, T0, E_K.SS, R)
    K_ES <- Temp.Resp.Eq(K_ES_T0, temp, T0, E_K.ES, R)
    V_LD <- Temp.Resp.NonEq(V_LD_T0, temp, T0, E_V.LD, R)
    V_RD <- Temp.Resp.NonEq(V_RD_T0, temp, T0, E_V.RD, R)
    V_SU <- Temp.Resp.NonEq(V_SU_T0, temp, T0, E_V.SU, R)
    Mm   <- Temp.Resp.Eq(Mm_T0, temp, T0, E_m, R)
    Em   <- Temp.Resp.Eq(Em_T0, temp, T0, E_m, R)
    
    F_ml.lc   <- F_ml.lc(litter_m)
    F_sl.rc   <- F_sl.rc(litter_struct)
    F_mc_lc   <- F_mc_lc(MC, Mm, mcsc_f)
    F_lc.scw  <- F_lc.scw(LC, RC, ECw, V_LD, K_LD, K_RD, theta)
    F_rc.scw  <- F_rc.scw(LC, RC, ECw, V_RD, K_LD, K_RD, theta)
    F_mc_scw  <- F_mc_scw(MC, Mm, mcsc_f)
    F_ecw.scw <- F_ecw.scw(ECw, Em)
    F_scw.sci <- F_sci.scw(SCw, SCi, dtheta, theta, theta_fc)
    F_scw.scs <- F_scw.scs(SCw, SCs, ECw, ECs, M, K_SS, K_ES, theta)
    F_scw.scm <- F_scw.scm(SCw, SCm, D_S0, theta, delta)
    F_scm_co2 <- F_scm_co2(SCm, MC, t_MC, CUE, theta, V_SC, K_SU)
    F_scm.mc  <- F_scm.mc(SCm, MC, t_MC, CUE, theta, V_SC, K_SU)
    F_mc.ecm  <- F_mc.ecm(MC, E_P)
    F_ecm.ecw <- F_ecm.ecw(SCw, SCm, D_E0, theta, delta)
    F_ecw.ecs <- F_ecw.ecs(SCw, SCs, ECw, ECs, M, K_SS, K_ES, theta)
    
    # Define the rate changes for each state variable
    dLC  <- F_ml.lc + F_mc_lc - F_lc.scw
    dRC  <- F_sl.rc - F_rc.scw
    dSCw <- F_lc.scw + F_rc.scw + F_mc_scw + F_ecw.scw - F_scw.sci - F_scw.scs - F_scw.scm
    dSCs <- F_scw.scs
    dSCi <- F_scw.sci
    dSCm <- F_scw.scm - F_scm_co2 - F_scm.mc
    dECm <- F_mc.ecm - F_ecm.ecw
    dECw <- F_ecm.ecw - F_ecw.ecs - F_ecw.scw
    dECs <- F_ecw.ecs
    dMC  <- F_scm.mc - F_mc.ecm - F_mc_lc - F_mc_scw
    dCO2 <- F_scm_co2
    
    # Output as a list
    list(c(dLC, dRC, dSCw, dSCs, dSCi, dSCm, dECw, dECs, dECm, dMC, CO2), 
         c(K_LD, K_RD, K_SU, K_SS, K_ES, K_LD, K_RD, V_LD, V_RD, V_SU, Mm, Em))
    
  }) # end of with...
} # end of model.run

model.out <- as.data.frame(ode(state, times, model.run, parameters))

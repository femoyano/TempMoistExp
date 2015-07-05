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

eq.run <- 1 # should the input data be recylced until equilibrium is reached?

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

### Inputs =====================================================================
  
# Load spatio_temporal input data
source("load_inputs.R")

# Difine model times: start, end and delt (resolution) times
start <- 1
end   <- forcing.data$day[length(forcing.data$day)]
delt  <- 0.1

# Model definition ====
model.run <- function(start, end, delt, state, parameters, litter.data, forcing.data) { # must be defined as: func <- function(t, y, parms,...) for use with ode

  with(as.list(c(state, parameters)), {
    
    # Define model time step vector
    times <- seq(start, end, delt)
    nt    <- length(times)
    
    input_temp    <- forcing.data$temp   # [K] soil temperature
    input_moist   <- forcing.data$moist  # [m^3 m^-3] soil volumetric water content
    times_forcing <- forcing.data$day    # time vector of the forcing data
    
    input_litter_m <- litter.data$litter_m # [gC m^2] metabolic litter
    input_litter_s <- litter.data$litter_s # [gC m^2] structural litter
    times_litter   <- litter.data$day      # time vector of the litter data
    
    # Interpolate input variables
    litter_m <- approx(times_litter, input_litter_m, xout=times, rule=2)$y  # [gC]
    litter_s <- approx(times_litter, input_litter_s, xout=times, rule=2)$y  # [gC]
    temp     <- approx(times_forcing, input_temp, xout=times, rule=2)$y     # [K]
    theta_s  <- approx(times_forcing, input_moist, xout=times, rule=2)$y    # [m^3 m^-3] specific water content
    theta    <- theta_s * depth    # [m^3] total water content
    theta_d  <- c(0,diff(theta))   # [m^3] change in water content relative to previous time step
    
    # Calculate spatially dependent variables
    M         <- M_spec * depth * dens_min * (1 - phi)  # [gC] Total C-equivalent mineral surface for sorption
    b         <- 2.91 + 15.9 * clay                    # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
    psi_sat   <- exp(6.5 - 1.3 * sand) / 1000   # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
    Rth       <- phi * (psi_sat / psi_Rth)^(1 / b) # [kPa] Threshold water content for mic. respiration (water retention formula from Campbell 1984)
    theta_Rth <- Rth * depth
    fc        <- phi * (psi_sat / psi_fc)^(1 / b)  # [kPa] Field capacity water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
    theta_fc  <- fc * depth
    
    # Calculate temporally changing variables
    K_LD <- Temp.Resp.Eq(K_LD_0, temp, T0, E_K.LD, R)
    K_RD <- Temp.Resp.Eq(K_RD_0, temp, T0, E_K.RD, R)
    K_SU <- Temp.Resp.Eq(K_SU_0, temp, T0, E_K.SU, R)
    K_SM <- Temp.Resp.Eq(K_SM_0, temp, T0, E_K.SM, R)
    K_EM <- Temp.Resp.Eq(K_EM_0, temp, T0, E_K.EM, R)
    V_LD <- Temp.Resp.NonEq(V_LD_0, temp, T0, E_V.LD, R)
    V_RD <- Temp.Resp.NonEq(V_RD_0, temp, T0, E_V.RD, R)
    V_SU <- Temp.Resp.NonEq(V_SU_0, temp, T0, E_V.SU, R)
    Mm   <- Temp.Resp.Eq(Mm_0, temp, T0, E_m, R)
    Em   <- Temp.Resp.Eq(Em_0, temp, T0, E_m, R)
    
    # Create matrix to hold output
    out <- matrix(ncol = 1 + length(initial_state), nrow=nt)
        
    for(i in 1:length(times)) {
      
#       if(i == 1598) {browser()}
      
      F_ml.lc   <- F_ml.lc(litter_m[i])
      F_sl.rc   <- F_sl.rc(litter_s[i])
      F_mc.lc   <- F_mc.lc(MC, Mm[i], mcsc_f)
      F_lc.scw  <- F_lc.scw(LC, RC, ECw, V_LD[i], K_LD[i], K_RD[i], theta[i])
      F_rc.scw  <- F_rc.scw(LC, RC, ECw, V_RD[i], K_LD[i], K_RD[i], theta[i])
      F_mc.scw  <- F_mc.scw(MC, Mm[i], mcsc_f)
      F_ecw.scw <- F_ecw.scw(ECw, Em[i])
      F_scw.sci <- F_scw.sci(SCw, SCi, theta_d[i], theta[i], theta_fc)
      F_scw.scs <- F_scw.scs(SCw, SCs, ECw, ECs, M, K_SM[i], K_EM[i], theta[i])
      F_scw.scm <- F_scw.scm(SCw, SCm, D_S0, theta_s[i], dist, phi, Rth)
      F_scm.co2 <- F_scm.co2(SCm, MC, t_MC, CUE, theta[i], V_SU[i], K_SU[i])
      F_scm.mc  <- F_scm.mc(SCm, MC, t_MC, CUE, theta[i], V_SU[i], K_SU[i])
      F_mc.ecm  <- F_mc.ecm(MC, E_P)
      F_ecm.ecw <- F_ecm.ecw(ECm, ECw, D_E0, theta_s[i], dist, phi, Rth)
      F_ecw.ecs <- F_ecw.ecs(SCw, SCs, ECw, ECs, M, K_SM[i], K_EM[i], theta[i])
      
      out[i,] <- c(times[i], LC, RC, SCw, SCs, SCi, SCm, ECw, ECs, ECm, MC, CO2)
      
      # Define the rate changes for each state variable
      dLC  <- F_ml.lc + F_mc.lc - F_lc.scw
      dRC  <- F_sl.rc - F_rc.scw
      dSCw <- F_lc.scw + F_rc.scw + F_mc.scw + F_ecw.scw - F_scw.sci - F_scw.scs - F_scw.scm
      dSCs <- F_scw.scs
      dSCi <- F_scw.sci
      dSCm <- F_scw.scm - F_scm.co2 - F_scm.mc
      dECm <- F_mc.ecm - F_ecm.ecw
      dECw <- F_ecm.ecw - F_ecw.ecs - F_ecw.scw
      dECs <- F_ecw.ecs
      dMC  <- F_scm.mc - F_mc.ecm - F_mc.lc - F_mc.scw
      dCO2 <- F_scm.co2
      
      LC <- LC + dLC * delt
      RC <- RC + dRC * delt
      SCw <- SCw + dSCw * delt
      SCs <- SCs + dSCs * delt
      SCi <- SCi + dSCi * delt
      SCm <- SCm + dSCm * delt
      ECw <- ECw + dECw * delt
      ECs <- ECs + dECs * delt
      ECm <- ECm + dECm * delt
      MC <- MC + dMC * delt
      CO2 <- CO2 + dCO2 * delt 
    }
    
    colnames(out) <- c("time", "LC", "RC", "SCw", "SCs", "SCi", "SCm", "ECw", "ECs", "ECm", "MC", "CO2")
    
    out <- cbind(as.data.frame(out), litter_m, litter_s, temp, theta, theta_s, theta_d)
    
  }) # end of with...

} # end of model.run

model.out <- model.run(start, end, delt, initial_state, parameters, litter.data, forcing.data)


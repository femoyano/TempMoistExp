### ModelMin.R ================================================================

### Documentation ==============================================================
# Main function running the model.
# This function prepares the input data, then loops over the time variable where
# it calls the flux functions, calculates the changes in each pool,
# and returns the values for each time point in a data frame.

# ModelMin version has the minimum number of processes:
# Only 1 litter pool, no diffusion, no sorbtion, no immobile C, microbe implicit.
### ============================================================================

ModelMin <- function(eq.run, start, end, delt, state, parameters, litter.data, forcing.data) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  
  with(as.list(c(state, parameters)), {
    
    # Create model time step vector
    times <- seq(start, end, delt)
    nt    <- length(times)
    
    # Repeat input data when shorter than end time
    temp           <- forcing.data$temp    # [K] soil temperature
    theta          <- forcing.data$moist   # [m^3 m^-3] soil volumetric water content
    times_forcing  <- forcing.data$day     # time vector of the forcing data
    litter_m       <- litter.data$litter_m # [gC m^2] metabolic litter
    litter_s       <- litter.data$litter_s # [gC m^2] structural litter
    times_litter   <- litter.data$day      # time vector of the litter data
    
    if(eq.run) {
      temp  <- rep(temp, length.out = end)
      theta <- rep(theta, length.out = end)
      litter_m <- rep(litter_m,  length.out = end)
      litter_s <- rep(litter_s,  length.out = end)
      times_forcing <- 1:end
      times_litter <- 1:end
    }
    
    # Interpolate input variables
    litter_m <- approx(times_litter, litter_m, xout=times, rule=2)$y  # [gC]
    litter_s <- approx(times_litter, litter_s, xout=times, rule=2)$y  # [gC]
    temp     <- approx(times_forcing, temp, xout=times, rule=2)$y     # [K]
    theta_s  <- approx(times_forcing, theta, xout=times, rule=2)$y    # [m^3 m^-3] specific water content
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
    
    setbreak <- 0
    
    for(i in 1:length(times)) {
      
#       if(i == 15) {browser()}
#       browser()
      
      # Write out values at current time
      out[i,] <- c(times[i], LC, RC, SCw, SCs, SCi, SCm, ECw, ECs, ECm, MC, CO2)
      
      # Calculate all fluxes
      F_ml.lc   <- F_ml.lc(litter_m[i])
      F_sl.lc   <- F_sl.rc(litter_s[i])
      F_lc.scw  <- F_lc.scw(LC, RC, ECw, V_LD[i], K_LD[i], K_RD[i], theta[i])
#       F_rc.scw  <- F_rc.scw(LC, RC, ECw, V_RD[i], K_LD[i], K_RD[i], theta[i])
#       F_scw.sci <- F_scw.sci(SCw, SCi, theta_d[i], theta[i], theta_fc)
#       F_scw.scs <- F_scw.scs(SCw, SCs, ECw, ECs, M, K_SM[i], K_EM[i], theta[i])
#       F_scw.scm <- F_scw.scm(SCw, SCm, D_S0, theta_s[i], dist, phi, Rth)
      F_scw.co2 <- F_sc.co2(SCw, CUE, theta[i], V_SU[i], K_SU[i])
      F_scw.lc  <- F_sc.lc(SCw, CUE, theta[i], V_SU[i], K_SU[i], mcsc_f, E_P)
#       F_scm.mc  <- F_scm.mc(SCm, MC, t_MC, CUE, theta[i], V_SU[i], K_SU[i])
#       F_mc.scw  <- F_mc.scw(MC, Mm[i], mcsc_f)
#       F_mc.lc   <- F_mc.lc(MC, Mm[i], mcsc_f)
      F_scw.ecw <- F_sc.ec(SCw, CUE, theta[i], V_SU[i], K_SU[i], E_P)
#       F_ecm.ecw <- F_ecm.ecw(ECm, ECw, D_E0, theta_s[i], dist, phi, Rth)
#       F_ecw.ecs <- F_ecw.ecs(SCw, SCs, ECw, ECs, M, K_SM[i], K_EM[i], theta[i])
      F_ecw.scw <- F_ecw.scw(ECw, Em[i])
      
      # Define the rate changes for each state variable
      dLC  <- F_ml.lc + F_sl.lc + F_scw.lc - F_lc.scw
      dRC  <- 0
      dSCw <- F_lc.scw + F_ecw.scw - F_scw.co2 -  F_scw.lc - F_scw.ecw
      dSCs <- 0
      dSCi <- 0
      dSCm <- 0
      dECm <- 0
      dECw <- F_scw.ecw - F_ecw.scw
      dECs <- 0
      dMC  <- 0
      dCO2 <- F_scw.co2
      
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
      
      # If spinup, stop at equilibirum
      if (eq.run & (i*delt)>=24) { 
        if (CheckEquil(out[,2], out[,3], i, eq.mpd)) {
          print(paste("Yearly change in the sum of LC and RC below equilibrium max. change value of ", eq.mpd, " at day ", i * delt,". Sum at equilibrium is ", LC[i]+RC[i],".",sep=""))
          setbreak <- TRUE
        }
      }
      if (setbreak) break
    } # end for loop
    
    
    colnames(out) <- c("time", "LC", "RC", "SCw", "SCs", "SCi", "SCm", "ECw", "ECs", "ECm", "MC", "CO2")
    
    out <- cbind(as.data.frame(out), litter_m, litter_s, temp, theta, theta_s, theta_d)
    
    out <- out[1:i,]
    
  }) # end of with...
  
} # end of model.run

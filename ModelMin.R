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
    times_forcing  <- forcing.data[,1]     # time vector of the forcing data
    litter_m       <- litter.data$litter_m # [gC m^2] metabolic litter
    litter_s       <- litter.data$litter_s # [gC m^2] structural litter
    litter_d       <- litter.data$litter_d # [gC m^2] doc from litter
    times_litter   <- litter.data[,1]      # time vector of the litter data
    
    if(eq.run) {
      temp  <- rep(temp, length.out = end)
      theta <- rep(theta, length.out = end)
      litter_m <- rep(litter_m,  length.out = end)
      litter_s <- rep(litter_s,  length.out = end)
      litter_d <- rep(litter_d,  length.out = end)
      times_forcing <- 1:end
      times_litter <- 1:end
    }
    # Interpolate input variables
    litter_m <- approx(times_litter, litter_m, xout=times, rule=2)$y  # [gC]
    litter_s <- approx(times_litter, litter_s, xout=times, rule=2)$y  # [gC]
    litter_d <- approx(times_litter, litter_d, xout=times, rule=2)$y  # [gC]
    temp     <- approx(times_forcing, temp, xout=times, rule=2)$y     # [K]
    theta_s  <- approx(times_forcing, theta, xout=times, rule=2)$y    # [m^3 m^-3] specific water content
    theta    <- theta_s * depth    # [m^3] total water content
    theta_d  <- c(0,diff(theta))   # [m^3] change in water content relative to previous time step
    
    # Calculate spatially dependent variables
#     M         <- M_spec * depth * dens_min * (1 - phi)  # [gC] Total C-equivalent mineral surface for sorption
#     b         <- 2.91 + 15.9 * clay                    # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
#     psi_sat   <- exp(6.5 - 1.3 * sand) / 1000   # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
#     Rth       <- phi * (psi_sat / psi_Rth)^(1 / b) # [kPa] Threshold water content for mic. respiration (water retention formula from Campbell 1984)
#     theta_Rth <- Rth * depth
#     fc        <- phi * (psi_sat / psi_fc)^(1 / b)  # [kPa] Field capacity water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
#     theta_fc  <- fc * depth
    
    # Calculate temporally changing variables
    K_D  <- Temp.Resp.Eq(K_D_0, temp, T0, E_K.D, R)
    K_U  <- Temp.Resp.Eq(K_U_0, temp, T0, E_K.U, R)
#     K_SM <- Temp.Resp.Eq(K_SM_0, temp, T0, E_K.SM, R)
#     K_EM <- Temp.Resp.Eq(K_EM_0, temp, T0, E_K.EM, R)
    V_D  <- Temp.Resp.NonEq(V_D_0, temp, T0, E_V.D, R)
    V_U  <- Temp.Resp.NonEq(V_U_0, temp, T0, E_V.U, R)
    Mm   <- Temp.Resp.Eq(Mm_0, temp, T0, E_m, R)
    Em   <- Temp.Resp.Eq(Em_0, temp, T0, E_m, R)
    
    # Create matrix to hold output
    out <- matrix(ncol = 1 + length(initial_state), nrow=nt)
    
    setbreak <- 0 # break flag for spinup runs
    
    for(i in 1:length(times)) {
      
      browser()
      
      # Write out values at current time
      out[i,] <- c(times[i], PC, SC, EC, MC, CO2)
      
      # Calculate all fluxes
      F_ml.pc   <- F_litter(litter_m[i])
      F_sl.pc   <- F_litter(litter_s[i])
      F_dl.sc   <- F_litter(litter_d[i])
      F_pc.sc   <- F_decomp(PC, EC, V_D[i], K_D[i])
      F_sc.co2  <- F_uptake(SC, MC, V_U[i], K_U[i]) * (1-CUE)
      F_sc.mc   <- F_uptake(SC, MC, V_U[i], K_U[i]) * CUE
      F_mc.ec   <- F_mc.ec(MC, Mm[i], E_P)
      F_mc.pc   <- F_mc.pc(MC, Mm[i], mcsc_f)
      F_mc.sc   <- F_mc.sc(MC, Mm[i], mcsc_f)
      F_ec.sc   <- F_ec.sc(EC, Em[i])
      
      # Define the rate changes for each state variable
      dPC  <- F_ml.pc + F_sl.pc + F_mc.pc - F_pc.sc
      dSC  <- F_dl.sc + F_pc.sc + F_ec.sc + F_mc.sc - F_sc.co2 - F_sc.mc
      dEC  <- F_mc.ec - F_ec.sc
      dMC  <- F_sc.mc - F_mc.ec - F_mc.pc - F_mc.sc
      dCO2 <- F_sc.co2
      
      PC  <- PC + dPC * delt
      SC  <- SC + dSC * delt
      EC  <- EC + dEC * delt
      MC  <- MC + dMC * delt
      CO2 <- CO2 + dCO2 * delt 
      
      # If spinup, stop at equilibirum
      if (eq.run & (i * delt * tunit / year)>=2) { 
        if (CheckEquil(out[,2], i, eq.md)) {
          print(paste("Yearly change in PC below equilibrium max. change value of ", eq.md, " at day ", i * delt,". Value at equilibrium is ", PC,".",sep=""))
          setbreak <- TRUE
        }
      }
      if (setbreak) break
    } # end for loop
    
    
    colnames(out) <- c("time", "PC", "SC", "EC", "MC", "CO2")
    
    out <- cbind(as.data.frame(out), litter_m, litter_s, temp, theta, theta_s, theta_d)
    
    out <- out[1:i,]
    
  }) # end of with...
  
} # end of model.run

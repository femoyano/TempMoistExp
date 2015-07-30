### Model.R ================================================================

### Documentation ==============================================================
# Main function running the model.
# This function prepares the input data, then loops over the time variable where
# it calls the flux functions, calculates the changes in each pool,
# and returns the values for each time point in a data frame.

# ModelMin version has the minimum number of processes:
# Only 1 litter pool, no diffusion, no sorbtion, no immobile C, microbe implicit.
### ============================================================================

Model <- function(spinup, eq.stop, start, end, tstep, tsave, initial_state, parameters, litter.data, forcing.data) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  
  with(as.list(c(initial_state, parameters)), {
    
    # Create model time step vector
    times <- seq(start, end)
    nt    <- length(times)
    
    temp           <- forcing.data$temp      # [K] soil temperature
    moist          <- forcing.data$moist     # [m3 m-3] specific soil volumetric moisture
    times_forcing  <- forcing.data[,1]       # [t_step] time vector of the forcing data
    litter_sc      <- litter.data$litter_met # [mgC m^2] metabolic litter going to sc
    litter_pc      <- litter.data$litter_str # [mgC m^2] structural litter going to pc
    times_litter   <- litter.data[,1]        # time vector of the litter data

    # Interpolate input variables
    litter_pc <- approx(times_litter, litter_pc, xout=times, rule=2)$y
    litter_sc <- approx(times_litter, litter_sc, xout=times, rule=2)$y
    temp      <- approx(times_forcing, temp, xout=times, rule=2)$y
    moist     <- approx(times_forcing, moist, xout=times, rule=2)$y
    
    # If spinup, repeat input data
    if(spinup) {
      temp  <- rep(temp, length.out = end)
      moist <- rep(moist, length.out = end)
      litter_pc <- rep(litter_pc,  length.out = end)
      litter_sc <- rep(litter_sc,  length.out = end)
    }
    
    # Calculate spatially dependent variables
    moist_d   <- c(0, diff(moist_t))                # [m^3] change in water content relative to previous time step
    b         <- 2.91 + 15.9 * clay                 # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
    psi_sat   <- exp(6.5 - 1.3 * sand) / 1000       # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
    Rth       <- ps * (psi_sat / psi_Rth)^(1 / b)   # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
    fc        <- ps * (psi_sat / psi_fc)^(1 / b)    # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
    M         <- 0.0002 * (100 * clay)^0.6 * pd * (1 - ps) # [g cm-3] Total C-equivalent mineral surface for sorption (Mayes et al. 2012)
    
    # Calculate temporally changing variables
    K_D <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K.D, R)
    K_U <- Temp.Resp.Eq(K_U_ref, temp, T_ref, E_K.U, R)
    V_D <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V.D, R)
    V_U <- Temp.Resp.Eq(V_U_ref, temp, T_ref, E_V.U, R)
    CUE <- CUE_ref
    Mm  <- Temp.Resp.Eq(Mm_ref, temp, T_ref, E_Mm, R)
    Em  <- Temp.Resp.Eq(Em_ref, temp, T_ref, E_Em, R)
    
    # Create matrix to hold output
    out <- matrix(ncol = 1 + length(initial_state), nrow = floor(nt * tstep / tsave))
    
    setbreak <- 0 # break flag for spinup runs
    
    for(i in 1:length(times)) {

      # Write out values at save time intervals
      if((i * tstep) %% (tsave) == 0) {
        j <- i * tstep / tsave
        out[j,] <- c(times[i], PC, SCb, SCm, SCs, ECb, ECm, ECs, MC, CO2)
      }

      # Calculate all fluxes
      F_sl.pc    <- F_litter(litter_pc[i])
      PC <- PC + F_sl.pc
      
      F_ml.scb   <- F_litter(litter_sc[i])
      SCb <- SCb + F_ml.scb
      
      F_pc.scb   <- F_decomp(PC, ECb, V_D[i], K_D[i], moist[i], fc, depth)
      PC  <- PC  - F_pc.scb
      SCb <- SCb + F_pc.scb
      
      F_scb.scs  <- F_sorp(SCb, SCs, ECb, ECs, M, K_SM, K_EM, moist, fc, depth)
      SCb <- SCb - F_scb.scs
      SCc <- SCs + F_scb.scs
      
      F_ecb.ecs  <- F_sorp(ECb, ECs, SCb, SCs, M, K_EM, K_SM, moist, fc, depth)
      ECb <- ECb - 
      F_scm.co2  <- F_uptake(SCm, MC, V_U[i], K_U[i], moist[i], fc, depth) * (1-CUE)
      F_scm.mc   <- F_uptake(SCm, MC, V_U[i], K_U[i], moist[i], fc, depth) * CUE
      F_mc.ecm   <- F_mc.ecm(MC, E_p, Mm[i])
      F_mc.pc    <- F_mc.pc(MC, Mm[i], mcpc_f)
      F_mc.scb   <- F_mc.scb(MC, Mm[i], mcpc_f)
      F_ecb.scb  <- F_ecb.scb(ECb, Em[i])
      F_scb.scm  <- F_diffusion(SCb, SCm, D_S0, moist[i], dist, ps, Rth)
      F_ecm.ecb  <- F_diffusion(ECm, ECb, D_E0, moist[i], dist, ps, Rth)

      
      # Define the rate changes for each state variable
      dPC  <- F_sl.pc + F_mc.pc - F_pc.scb
      dSCb <- F_ml.scb + F_pc.scb + F_ecb.scb + F_mc.scb - F_scb.scm
      dECb <- F_ecm.ecb - F_ecb.scb
      dSCm <- F_scb.scm - F_scm.co2 - F_scm.mc
      dECm <- F_mc.ecm - F_ecm.ecb
      dMC  <- F_scm.mc - F_mc.ecm - F_mc.pc - F_mc.scb
      dCO2 <- F_scm.co2

      # Clalculate the new pool size
      PC  <- PC  + dPC
      SCb <- SCb + dSCb
      SCm <- SCm + dSCm
      ECb <- ECb + dECb
      ECm <- ECm + dECm
      MC  <- MC  + dMC
      CO2 <- CO2 + dCO2

      # This section limites the flux to the size of the pool itself, avoiding negative values. Should not be necessary when using DE solver.
      PC  <- ifelse(PC > 0, PC, 0)
      SCb <- ifelse(SCb > 0, SCb, 0)
      SCm <- ifelse(SCm > 0, SCm, 0)
      ECb <- ifelse(ECb > 0, ECb, 0)
      ECm <- ifelse(ECm > 0, ECm, 0)
      MC  <- ifelse(MC > 0, MC, stop("MC has reached a value of 0. This should not happen."))
      
      # Check for stop in case of spinup and stop at equilibirum are set
      if (spinup & eq.stop & (i * tstep / year) >= 10 & ((i * tstep / year) %% 5) == 0) { # If it is a spinup run and time is over 10 years and multiple of 5 years, then ...
        if (CheckEquil(out[,2], i, eq.md, tsave, year)) {
          print(paste("Yearly change in PC below equilibrium max change value of", eq.md, "at", t_step, i,". Value at equilibrium is ", PC, ".", sep=" "))
          setbreak <- TRUE
        }
      }
      if (setbreak) break
    } # end for loop
    
    colnames(out) <- c("time", "PC", "SCb", "SCm", "SCs", "ECb", "ECm", "ECs", "MC", "CO2")
    
    out <- as.data.frame(out)
    out <- out[1:(floor(i * tstep / tsave)),]
    
  }) # end of with...
  
} # end of model.run

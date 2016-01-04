#### Model_stepwise.R ================================================================

#### Documentation ==============================================================
# Main function running the model.
# This version runs with a fixed time step, defined by 'tstep'.
# It loops over the time variable where
# it calls the flux functions, calculates the changes in each pool,
# and returns the values for each time point in a data frame.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ============================================================================

Model_stepwise <- function(spinup, eq.stop, times, tstep, tsave, initial_state, pars) {
  
  with(as.list(c(initial_state, pars)), {
    
    # Create matrix to hold output
    extra <- 2 # number of extra variables to save (temp, moist, ...)
    out <- matrix(ncol = 1 + extra + length(initial_state), nrow = floor(length(times) * tstep / tsave))
    colnames(out) <- c("time", "PC", "SCw", "SCs", "ECw", "ECm", "MC", "CO2", "temp", "moist")
    
    setbreak   <- 0 # break flag for spinup runs
    
#     # Set initial values for variables that can be optionally saved
#     F_sl.pc   <- F_ml.scw <- F_pc.scw <- F_scw.scs <- 0
#     F_ecm.ecb <- F_scw.diff <- F_scw.co2 <- F_scw.ecm <- F_scw.pc <- 0
#     F_ecm.ecb <- F_ecm.scw  <- F_ecb.scw <- 0
    
    # Loop through each time step
    for(i in 1:length(times)) {
      
      # set time used for interpolating input data.
      t <- times[i]
      if(spinup) t <- t %% end # this causes spinups to repeat the input data
      
      # Calculate the input and forcing at time t
      litter_str_i <- Approx_litter_str(t)
      litter_met_i <- Approx_litter_met(t)
      temp_i       <- Approx_temp(t)
      moist_i      <- Approx_moist(t)
      
      # Calculate temporally changing variables
      K_D     <- Temp.Resp.Eq(K_D_ref , temp_i, T_ref, E_K.D, R)
      ka.s    <- Temp.Resp.Eq(ka.s.ref, temp_i, T_ref, E_ka , R)
      kd.s    <- Temp.Resp.Eq(kd.s.ref, temp_i, T_ref, E_kd , R)
      V_D     <- Temp.Resp.Eq(V_D_ref , temp_i, T_ref, E_V.D, R)
      Mm      <- Temp.Resp.Eq(Mm_ref  , temp_i, T_ref, E_Mm , R)
      Em      <- Temp.Resp.Eq(Em_ref  , temp_i, T_ref, E_Em , R)
      CUE     <- CUE_ref
      
      # Write out values at save time intervals
      if((i * tstep) %% (tsave) == 0) {
        j <- i * tstep / tsave
        out[j,] <- c(times[i], PC, SCw, SCs, ECw, ECm, MC, CO2, temp_i, moist_i)
      }

      # Diffusion calculations
      # Note: for diffusion fluxes, no need to divide by moist and depth to get specific
      # concentrations and multiply again for total since they cancel out.
      if(moist_i <= Rth) diffmod <- 0 else diffmod <- (ps - Rth)^1.5 * ((moist_i - Rth)/(ps - Rth))^2.5 # reference?
      SC.diff <- D_S0 * (SCw - 0) * diffmod / dist
      EC.diff <- D_E0 * (ECm - ECw) * diffmod / dist
      
      ### Calculate all fluxes ------
      
      # Input rate
      F_sl.pc    <- litter_str_i
      F_ml.scw   <- litter_met_i
      
      # Decomposition rate
      F_pc.scw   <- F_decomp(PC, ECw, V_D, K_D, moist_i, fc, depth)
      
      # Adsorption/desorption
      if(flag.ads) {
        F_scw.scs  <- F_adsorp(SCw, SCs, Md, ka.s, moist_i, fc, depth)
        F_scs.scw  <- F_desorp(SCs, kd.s, moist_i, fc)
      } else {
        F_scw.scs <- 0
        F_scs.scw <- 0
      }
      
      # Microbial growth, mortality, respiration and enzyme production
      if(flag.mic) {
        F_scw.mc  <- SC.diff * CUE # concentration at microbe asumed 0
        F_scw.co2 <- SC.diff * (1 - CUE) # concentration at microbe asumed 0
        F_mc.pc   <- MC * Mm
        F_mc.ecm  <- MC * Ep
        F_scw.pc  <- 0
        F_scw.ecm <- 0
      } else {
        F_scw.mc  <- 0
        F_mc.pc   <- 0
        F_mc.ecm  <- 0
        F_scw.co2 <- SC.diff * (1 - CUE)
        F_scw.pc  <- SC.diff * CUE * (1 - Ef)
        F_scw.ecm <- SC.diff * CUE * Ef
      }
      
      F_ecm.ecw  <- EC.diff
      
      # Enzyme decay
      F_ecw.scw  <- ECw * Em
      F_ecm.scw  <- ECm * Em
      
      ## Rate of change calculation for state variables ---------------
      PC  <- PC  + F_sl.pc   + F_scw.pc  + F_mc.pc   - F_pc.scw
      SCw <- SCw + F_ml.scw  + F_pc.scw  + F_scs.scw + F_ecw.scw + F_ecm.scw -
                   F_scw.scs - F_scw.mc  - F_scw.co2 - F_scw.pc  - F_scw.ecm
      SCs <- SCs + F_scw.scs - F_scs.scw
      ECw <- ECw + F_ecm.ecw - F_ecw.scw 
      ECm <- ECm + F_scw.ecm + F_mc.ecm  - F_ecm.ecw - F_ecm.scw
      MC  <- MC  + F_scw.mc  - F_mc.pc   - F_mc.ecm
      CO2 <- CO2 + F_scw.co2
      
      # Check for equilibirum conditions: will stop if the change in PC in gC m-3 y-1 is smaller than eq.md
      if (eq.stop & (i * tstep / year) >= 10 & ((i * tstep / year) %% 5) == 0) { # If it is a spinup run and time is over 10 years and multiple of 5 years, then ...
        if (CheckEquil(out[,2], i, eq.md, tsave, tstep, year, depth)) {
          print(paste("Yearly change in PC below equilibrium max change value of", eq.md, "at", t_step, i,". Value at equilibrium is ", PC, ".", sep=" "))
          setbreak <- TRUE
        }
      }
      if (setbreak) break
    } # end for loop
    
#     out <- as.data.frame(out)
    out <- out[1:(floor(i * tstep / tsave)),]
    
    return(out)
    
  }) # end of with(...
  
} # end of model.run

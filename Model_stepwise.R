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
    colnames(out) <- c("time", "C_P", "C_D", "C_A", "C_Ew", "C_Em", "C_M", "C_R", "temp", "moist")
    
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
      K_D     <- Temp.Resp.Eq(K_D_ref , temp_i, T_ref, E_KD, R)
      k_ads    <- Temp.Resp.Eq(k_ads_ref, temp_i, T_ref, E_ka , R)
      k_des    <- Temp.Resp.Eq(k_des_ref, temp_i, T_ref, E_kd , R)
      V_D     <- Temp.Resp.Eq(V_D_ref , temp_i, T_ref, E_VD, R)
      r_md      <- Temp.Resp.Eq(r_md_ref  , temp_i, T_ref, E_r_md , R)
      r_ed      <- Temp.Resp.Eq(r_ed_ref  , temp_i, T_ref, E_r_ed , R)
      f_gr     <- f_gr_ref
      
      # Write out values at save time intervals
      if((i * tstep) %% (tsave) == 0) {
        j <- i * tstep / tsave
        out[j,] <- c(times[i], C_P, C_D, C_A, C_Ew, C_Em, C_M, C_R, temp_i, moist_i)
      }

      # Diffusion calculations
      # Note: for diffusion fluxes, no need to divide by moist and depth to get specific
      # concentrations and multiply again for total since they cancel out.
      if(moist_i <= Rth) diffmod <- 0 else diffmod <- (ps - Rth)^1.5 * ((moist_i - Rth)/(ps - Rth))^2.5 # reference?
      C_D.diff <- D_S0 * (C_D - 0) * diffmod / d_pm
      C_E.diff <- D_E0 * (C_Em - C_Ew) * diffmod / d_pm
      
      ### Calculate all fluxes ------
      
      # Input rate
      F_sl.pc    <- litter_str_i
      F_ml.scw   <- litter_met_i
      
      # Decomposition rate
      F_pc.scw   <- F_decomp(C_P, C_Ew, V_D, K_D, moist_i, fc, depth)
      
      # Adsorption/desorption
      if(flag.ads) {
        F_scw.scs  <- F_adsorp(C_D, C_A, Md, k_ads, moist_i, fc, depth)
        F_scs.scw  <- F_desorp(C_A, k_des, moist_i, fc)
      } else {
        F_scw.scs <- 0
        F_scs.scw <- 0
      }
      
      # Microbial growth, mortality, respiration and enzyme production
      if(flag.mic) {
        F_scw.mc  <- C_D.diff * f_gr # concentration at microbe asumed 0
        F_scw.co2 <- C_D.diff * (1 - f_gr) # concentration at microbe asumed 0
        F_mc.pc   <- C_M * r_md
        F_mc.ecm  <- C_M * f_me
        F_scw.pc  <- 0
        F_scw.ecm <- 0
      } else {
        F_scw.mc  <- 0
        F_mc.pc   <- 0
        F_mc.ecm  <- 0
        F_scw.co2 <- C_D.diff * (1 - f_gr)
        F_scw.pc  <- C_D.diff * f_gr * (1 - f_de)
        F_scw.ecm <- C_D.diff * f_gr * f_de
      }
      
      F_ecm.ecw  <- C_E.diff
      
      # Enzyme decay
      F_ecw.scw  <- C_Ew * r_ed
      F_ecm.scw  <- C_Em * r_ed
      
      ## Rate of change calculation for state variables ---------------
      C_P  <- C_P  + F_sl.pc   + F_scw.pc  + F_mc.pc   - F_pc.scw
      C_D <- C_D + F_ml.scw  + F_pc.scw  + F_scs.scw + F_ecw.scw + F_ecm.scw -
                   F_scw.scs - F_scw.mc  - F_scw.co2 - F_scw.pc  - F_scw.ecm
      C_A <- C_A + F_scw.scs - F_scs.scw
      C_Ew <- C_Ew + F_ecm.ecw - F_ecw.scw 
      C_Em <- C_Em + F_scw.ecm + F_mc.ecm  - F_ecm.ecw - F_ecm.scw
      C_M  <- C_M  + F_scw.mc  - F_mc.pc   - F_mc.ecm
      C_R <- C_R + F_scw.co2
      
      # Check for equilibirum conditions: will stop if the change in C_P in gC m-3 y-1 is smaller than eq.md
      if (eq.stop & (i * tstep / year) >= 10 & ((i * tstep / year) %% 5) == 0) { # If it is a spinup run and time is over 10 years and multiple of 5 years, then ...
        if (CheckEquil(out[,2], i, eq.md, tsave, tstep, year, depth)) {
          print(paste("Yearly change in C_P below equilibrium max change value of", eq.md, "at", t_step, i,". Value at equilibrium is ", C_P, ".", sep=" "))
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

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
#     F_sl.cp   <- F_ml.cd <- F_pc.cd <- F_cd.ca <- 0
#     F_cem.ecb <- F_cd.diff <- F_cd.co2 <- F_cd.cem <- F_cd.pc <- 0
#     F_cem.ecb <- F_cem.cd  <- F_ecb.cd <- 0
    
    # Loop through each time step
    for(i in 1:length(times)) {
      
      # set time used for interpolating input data.
      t <- times[i]
      if(spinup) t <- t %% end # this causes spinups to repeat the input data
      
      # Calculate the input and forcing at time t
      I_sl_i  <- Approx_I_sl(t)
      I_ml_i  <- Approx_I_ml(t)
      temp_i  <- Approx_temp(t)
      moist_i <- Approx_moist(t)
      
      # Calculate temporally changing variables
      K_D   <- Temp.Resp.Eq(K_D_ref, temp_i, T_ref, E_KD, R)
      k_ads <- Temp.Resp.Eq(k_ads_ref, temp_i, T_ref, E_ka , R)
      k_des <- Temp.Resp.Eq(k_des_ref, temp_i, T_ref, E_kd , R)
      V_D   <- Temp.Resp.Eq(V_D_ref, temp_i, T_ref, E_VD, R)
      r_md  <- Temp.Resp.Eq(r_md_ref, temp_i, T_ref, E_r_md , R)
      r_ed  <- Temp.Resp.Eq(r_ed_ref, temp_i, T_ref, E_r_ed , R)
      f_gr  <- f_gr_ref
      
      # Write out values at save time intervals
      if((i * tstep) %% (tsave) == 0) {
        j <- i * tstep / tsave
        out[j,] <- c(times[i], C_P, C_D, C_A, C_Ew, C_Em, C_M, C_R, temp_i, moist_i)
      }

      # Diffusion calculations
      # Note: for diffusion fluxes, no need to divide by moist and depth to get specific
      # concentrations and multiply again for total since they cancel out.
      # Diffusion modifiers for soil (texture), temperature and carbon content: D_sm, D_tm, D_cm
      if(moist_i <= Rth) D_sm <- 0 else D_sm <- (ps - Rth)^1.5 * ((moist_i - Rth)/(ps - Rth))^2.5 # reference?
      if(flag.dte) D_tm <- temp^8/T_ref^8 else D_tm <- 1
      if(flag.dce) {
        if(flag.dcf) D_cm <- C_P^(-1/3) / C_ref^(-1/3) else D_cm <- (C_P-C_max) / (C_ref-C_max)  # non-linear or linear response
      } else D_cm <- 1
      D_d <- D_d0 * D_sm * D_tm * D_cm
      D_e <- D_e0 * D_sm * D_tm * D_cm
      
      ### Calculate all fluxes ------
      
      # Input rate
      F_sl.cp    <- I_sl_i
      C_P <- C_P + F_sl.cp
      
      F_ml.cd   <- I_ml_i
      C_D <- C_D + F_ml.cd
      
      # Decomposition rate
      F_pc.cd   <- F_decomp(C_P, C_Ew, V_D, K_D, moist_i, fc, depth)
      C_D <- C_D + F_pc.cd
      C_P <- C_P - F_pc.cd
      
      # Adsorption/desorption
      if(flag.ads) {
        F_cd.ca  <- F_adsorp(C_D, C_A, Md, k_ads, moist_i, fc, depth)
        F_ca.cd  <- F_desorp(C_A, k_des, moist_i, fc)
      } else {
        F_cd.ca <- 0
        F_ca.cd <- 0
      }
      # check that flux is negative (would happen if starting values for C_A are too high)
      if(F_cd.ca < 0) warning("F_cd.ca is negative. Starting C_A too high?")
      # make sure fluxes are no larger than pool size
      if(F_cd.ca > C_D) F_cd.ca <- C_D; if(F_cd.ca < (-C_D)) F_cd.ca <- -C_D
      # update pool size before calculating next flux
      C_D <- C_D - F_cd.ca + F_ca.cd
      C_A <- C_A + F_cd.ca - F_ca.cd

      # Microbial growth, mortality, respiration and enzyme production
      if(flag.mic) {
        F_cd.cm  <- D_d * (C_D - 0) * f_gr # concentration at microbe asumed 0
        F_cd.co2 <- D_d * (C_D - 0) * (1 - f_gr) # concentration at microbe asumed 0
        F_cm.pc  <- C_M * r_md
        F_cm.cem <- C_M * f_me
        F_cd.pc  <- 0
        F_cd.cem <- 0
      } else {
        F_cd.cm  <- 0
        F_cm.pc  <- 0
        F_cm.cem <- 0
        F_cd.co2 <- D_d * (C_D - 0) * (1 - f_gr)
        F_cd.pc  <- D_d * (C_D - 0) * f_gr * (1 - f_de)
        F_cd.cem <- D_d * (C_D - 0) * f_gr * f_de
      }
      C_D  <- C_D  - F_cd.cm - F_cd.co2 - F_cd.pc - F_cd.cem
      C_P  <- C_P  + F_cd.pc + F_cm.pc
      C_Em <- C_Em + F_cd.cem + F_cm.cem
      C_R  <- C_R  + F_cd.co2
      C_M  <- C_M  + F_cd.cm - F_cm.pc - F_cm.cem
      
      F_cem.cew  <- D_e * (C_Em - C_Ew)
      C_Ew <- C_Ew + F_cem.cew 
      C_Em <- C_Em - F_cem.cew
      
      # Enzyme decay
      F_cew.cd  <- C_Ew * r_ed
      F_cem.cd  <- C_Em * r_ed
      C_D  <- C_D  + F_cew.cd + F_cem.cd
      C_Ew <- C_Ew - F_cew.cd 
      C_Em <- C_Em - F_cem.cd
      
      if(C_P < 0 | C_D < 0 | C_A < 0 | C_Ew < 0 | C_Em < 0 | C_M < 0) browser("Error: a pool became negative")
      
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

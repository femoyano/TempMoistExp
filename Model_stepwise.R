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
    extra <- 0 # number of extra variables to save (temp, moist, ...)
    out <- matrix(ncol = 1 + extra + length(initial_state), nrow = floor(length(times) * tstep / tsave))
    colnames(out) <- c("time", "C_P", "C_D", "C_E", "C_M", "C_R")
    
    setbreak   <- 0 # break flag for spinup runs
    
#     # Set initial values for variables that can be optionally saved
#     F_sl.cp   <- F_ml.cd <- F_pc.cd <- F_cd.ca <- 0
#     F_cd.diff <- F_cd.cr <- F_cd.ce <- F_cd.pc <- F_ce.cd <- 0
    
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
      K_D   <- Temp.Resp.Eq(K_D_ref, temp_i, T_ref, E_K, R)
      V_D   <- Temp.Resp.Eq(V_D_ref, temp_i, T_ref, E_V, R)
      r_md  <- Temp.Resp.Eq(r_md_ref, temp_i, T_ref, E_r_d , R)
      r_ed  <- Temp.Resp.Eq(r_ed_ref, temp_i, T_ref, E_r_d , R)
      f_gr  <- f_gr_ref
      
      # Write out values at save time intervals
      if((i * tstep) %% (tsave) == 0) {
        j <- i * tstep / tsave
        out[j,] <- c(times[i], C_P, C_D, C_E, C_M, C_R)
      }

      ## Diffusion calculations  --------------------------------------
      # Note: for diffusion fluxes, no need to divide by moist and depth to get specific
      # concentrations and multiply again for total since they cancel out.
      # Diffusion modifiers for soil (texture), temperature and carbon content: D_sm, D_tm, D_cm
      D_sm <- get.D_sm(moist, ps, Rth)
      D_tm <- get.D_tm(temp, T_ref)
      D_cm <- get.D_cm(C_P, C_ref, C_max)
      D_d <- D_d0 * D_sm * D_tm * D_cm
      D_e <- D_e0 * D_sm * D_tm * D_cm
      
      ### Calculate all fluxes ------
      
      # Input rate
      F_sl.cp    <- I_sl_i
      C_P <- C_P + F_sl.cp
      
      F_ml.cd   <- I_ml_i
      C_D <- C_D + F_ml.cd
      
      # Decomposition rate
      F_pc.cd   <- F_decomp(C_P, C_E, V_D, K_D, moist_i, fc, depth)
      C_D <- C_D + F_pc.cd
      C_P <- C_P - F_pc.cd
      
      # make sure flux is not larger than pool
      if(F_cd.ca > C_D) F_cd.ca <- C_D
      # avoid negative flux (would happen if C_A exceeds Md capacity)
      if(F_cd.ca < 0) F_cd.ca <- 0
      # update pool size before calculating next flux
      C_D <- C_D - F_cd.ca + F_ca.cd
      C_A <- C_A + F_cd.ca - F_ca.cd

      # Microbial growth, mortality, respiration and enzyme production
      if(flag.mic) {
        F_cd.cm <- U.cd * f_gr * (1 - f_ep)
        if(flag.mmr) {
          F_cm.cp <- C_M * r_md * (1 - f_mr)
          F_cm.cr <- C_M * r_md * f_mr  
        } else {
          F_cm.cp <- C_M * r_md
          F_cm.cr <- 0
        }
        F_cd.cp <- 0
      } else {
        F_cd.cm <- 0
        F_cm.cp <- 0
        F_cm.cr <- 0
        F_cd.cp <- U.cd * f_gr * (1 - f_ep)
      }
      F_cd.cr <- U.cd * (1 - f_gr)
      F_cd.ce <- U.cd * f_gr * f_ep
      
      C_D <- C_D - F_cd.cm - F_cd.cr - F_cd.pc - F_cd.ce
      C_P <- C_P + F_cd.pc + F_cm.pc
      C_E <- C_E + F_cd.ce + F_cd.ce
      C_R <- C_R + F_cd.cr
      C_M <- C_M + F_cd.cm - F_cm.pc
      
      # Enzyme decay
      F_ce.cd <- C_E * r_ed
      C_D <- C_D + F_ce.cd
      C_E <- C_E - F_ce.cd 

      if(C_P < 0 | C_D < 0 | C_E < 0 | C_M < 0) browser("Error: a pool became negative")
      
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

### Model.R ================================================================

### Documentation ==============================================================
# Main function running the model.
# This function prepares the input data, then loops over the time variable where
# it calls the flux functions, calculates the changes in each pool,
# and returns the values for each time point in a data frame.

# ModelMin version has the minimum number of processes:
# Only 1 litter pool, no diffusion, no sorbtion, no immobile C, microbe implicit.
### ============================================================================

Model <- function(spinup, eq.stop, start, end, tsave, state, parameters, litter.data, forcing.data) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  
  with(as.list(c(state, parameters)), {
    
    # Create model time step vector
    times <- seq(start, end)
    nt    <- length(times)
    
    # Repeat input data when shorter than end time
    temp            <- forcing.data$temp      # [K] soil temperature
    times_forcing   <- forcing.data[,1]       # [t_step] time vector of the forcing data
    litter_sc       <- litter.data$litter_met # [mgC m^2] metabolic litter going to sc
    litter_pc       <- litter.data$litter_str # [mgC m^2] structural litter going to pc
    times_litter    <- litter.data[,1]        # time vector of the litter data
    
    if(spinup) {
      temp  <- rep(temp, length.out = end)
      litter_pc <- rep(litter_pc,  length.out = end)
      litter_sc <- rep(litter_sc,  length.out = end)
      times_forcing <- 1:end
      times_litter <- 1:end
    }
    # Interpolate input variables
    litter_pc <- approx(times_litter, litter_pc, xout=times, rule=2)$y  # [mgC]
    litter_sc <- approx(times_litter, litter_sc, xout=times, rule=2)$y  # [mgC]
    temp     <- approx(times_forcing, temp, xout=times, rule=2)$y     # [K]
    
    # Calculate temporally changing variables
    K_D <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K.D, R)
    K_U <- Temp.Resp.Eq(K_U_ref, temp, T_ref, E_K.U, R)
    V_D <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V.D, R)
    V_U <- Temp.Resp.Eq(V_U_ref, temp, T_ref, E_V.U, R)
    CUE <- CUE_s * (temp - T_ref) + CUE_ref
    Mm  <- Mm_ref
    Em  <- Em_ref
    
    # Create matrix to hold output
    out <- matrix(ncol = 1 + length(initial_state), nrow = floor(nt * tunit / tsave) + 1)
    
    setbreak <- 0 # break flag for spinup runs
    
    for(i in 1:length(times)) {

      # Write out values at save time intervals
      if(i == 1 | (i * tunit) %% (tsave) == 0) {
        j <- i * tunit / tsave + 1
        out[j,] <- c(times[i], PC, SC, EC, MC, CO2)
      }
      
      # Calculate all fluxes
      F_sl.pc   <- F_litter(litter_pc[i])
      F_ml.sc   <- F_litter(litter_sc[i])
      F_pc.sc   <- F_decomp(PC, EC, V_D[i], K_D[i])
      F_sc.co2  <- F_uptake(SC, MC, V_U[i], K_U[i]) * (1-CUE[i])
      F_sc.mc   <- F_uptake(SC, MC, V_U[i], K_U[i]) * CUE[i]
      F_mc.ec   <- F_mc.ec(MC, E_p, Mm)
      F_mc.pc   <- F_mc.pc(MC, Mm, mcpc_f)
      F_mc.sc   <- F_mc.sc(MC, Mm, mcpc_f)
      F_ec.sc   <- F_ec.sc(EC, Em)
      
      # Define the rate changes for each state variable
      dPC  <- F_sl.pc + F_mc.pc - F_pc.sc
      dSC  <- F_ml.sc + F_pc.sc + F_ec.sc + F_mc.sc - F_sc.co2 - F_sc.mc
      dEC  <- F_mc.ec - F_ec.sc
      dMC  <- F_sc.mc - F_mc.ec - F_mc.pc - F_mc.sc
      dCO2 <- F_sc.co2

      PC  <- PC + dPC
      SC  <- SC + dSC
      EC  <- EC + dEC
      MC  <- MC + dMC
      CO2 <- CO2 + dCO2

      PC  <- ifelse(PC > 0, PC, 0)
      SC  <- ifelse(SC > 0, SC, 0)
      EC  <- ifelse(EC > 0, EC, 0)
      MC  <- ifelse(MC > 0, MC, stop("MC has reached a value of 0. This should not happen."))
      
      # If spinup and stop at equilibirum
      if (spinup & eq.stop & (i * tunit / year) >= 10 & ((i * tunit / year) %% 5) == 0) { # If it is a spinup run and time is over 10 years and multiple of 5 years, then ...
        if (CheckEquil(out[,2], i, eq.md, tsave, year)) {
          print(paste("Yearly change in PC below equilibrium max change value of", eq.md, "at", t_step, i,". Value at equilibrium is ", PC, ".", sep=" "))
          setbreak <- TRUE
        }
      }
      if (setbreak) break
    } # end for loop
    
    colnames(out) <- c("time", "PC", "SC", "EC", "MC", "CO2")
    
    out <- as.data.frame(out)
    out <- out[1:(floor(i * tunit / tsave) + 1),]
    
  }) # end of with...
  
} # end of model.run

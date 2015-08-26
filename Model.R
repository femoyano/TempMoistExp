### Model.R ================================================================

### Documentation ==============================================================
# Main function running the model.
# This function prepares the input data, then loops over the time variable where
# it calls the flux functions, calculates the changes in each pool,
# and returns the values for each time point in a data frame.

# ModelMin version has the minimum number of processes:
# Only 1 litter pool, no diffusion, no sorbtion, no immobile C, microbe implicit.
### ============================================================================

Model <- function(spinup, eq.stop, start, end, tstep, tsave, initial_state, parameters, temp, moist, litter_pc, litter_sc) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  
  with(as.list(c(initial_state, parameters)), {

    # Calculate spatially dependent variables
    #     moist_d   <- c(0, diff(moist * depth))            # [m^3] change in water content relative to previous time step
    b       <- 2.91 + 15.9 * clay                     # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
    psi_sat <- exp(6.5 - 1.3 * sand) / 1000           # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
    Rth     <- ps * (psi_sat / psi_Rth)^(1 / b)       # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
    fc      <- ps * (psi_sat / psi_fc)^(1 / b)        # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
    M       <- 200 * (100 * clay)^0.6 * pd * (1 - ps) # [g m-3] Total C-equivalent mineral surface for sorption (Mayes et al. 2012)
    
    # Calculate temporally changing variables
    K_D <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K.D, R)
#     K_U <- Temp.Resp.Eq(K_U_ref, temp, T_ref, E_K.U, R)
    K_SM <- Temp.Resp.Eq(K_SM_ref, temp, T_ref, E_K.SM, R)
    K_EM <- Temp.Resp.Eq(K_EM_ref, temp, T_ref, E_K.EM, R)
    V_D <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V.D, R)
#     V_U <- Temp.Resp.Eq(V_U_ref, temp, T_ref, E_V.U, R)
    CUE <- CUE_ref
#     Mm  <- Temp.Resp.Eq(Mm_ref, temp, T_ref, E_Mm, R)
    Em  <- Temp.Resp.Eq(Em_ref, temp, T_ref, E_Em, R)
    
    # Create matrix to hold output
    out <- matrix(ncol = 1 + length(initial_state), nrow = floor(nt * tstep / tsave))
    
    setbreak <- 0 # break flag for spinup runs
    
    for(i in 1:length(times)) {

      # Write out values at save time intervals
      if((i * tstep) %% (tsave) == 0) {
        j <- i * tstep / tsave
        out[j,] <- c(times[i], PC, SCw, SCs, ECb, ECm, ECs, CO2)
      }
# browser()
      # Calculate all fluxes
      F_sl.pc    <- F_litter(litter_pc[i])
      PC <- PC + F_sl.pc
      
      F_ml.scw   <- F_litter(litter_sc[i])
      SCw <- SCw + F_ml.scw
      
      F_pc.scw   <- F_decomp(PC, ECb, V_D[i], K_D[i], moist[i], fc, depth)
      PC  <- PC  - F_pc.scw
      SCw <- SCw + F_pc.scw

      F_scw.scs  <- F_sorp(SCw, SCs, ECb, ECs, M, K_SM[i], K_EM[i], moist[i], fc, depth)
      SCw <- SCw - F_scw.scs
      SCs <- SCs + F_scw.scs

      F_ecb.ecs  <- F_sorp(ECb, ECs, SCw, SCs, M, K_EM[i], K_SM[i], moist[i], fc, depth)
      ECb <- ECb - F_ecb.ecs
      ECs <- ECs + F_ecb.ecs
      
      F_scw.diff  <- F_diffusion(SCw, 0, D_S0, moist[i], dist, ps, Rth) # concentration at microbe assumed to be 0
      SCw  <- SCw - F_scw.diff
      
      F_scw.co2 <- F_scw.diff * (1 - CUE)
      CO2 <- CO2 + F_scw.co2
      
      F_scw.ecm  <- F_scw.diff * CUE * Ep
      ECm <- ECm + F_scw.ecm
        
      F_scw.pc <- F_scw.diff * CUE * (1 - Ep)
      PC <- PC + F_scw.pc
      
      F_ecm.ecb  <- F_diffusion(ECm, ECb, D_E0, moist[i], dist, ps, Rth)
      ECm <- ECm - F_ecm.ecb
      ECb <- ECb + F_ecm.ecb
      
      F_ecm.scw  <- F_ec.sc(ECm, Em[i])
      ECm <- ECm - F_ecm.scw
      SCw <- SCw + F_ecm.scw

      F_ecb.scw  <- F_ec.sc(ECb, Em[i])
      ECb <- ECb - F_ecb.scw
      SCw <- SCw + F_ecb.scw
      
      # This section makes sure that there are no negative C pools, which should not happen if conditions in flux functions are set correctly.
      if(PC * SCw * SCs * ECb * ECm * ECs <= 0) stop("A state variable became 0 or negative. This should not happen")
      
      # Check for equilibirum conditions
      if (spinup & eq.stop & (i * tstep / year) >= 10 & ((i * tstep / year) %% 5) == 0) { # If it is a spinup run and time is over 10 years and multiple of 5 years, then ...
        if (CheckEquil(out[,2], i, eq.md, tsave, tstep, year, depth)) {
          print(paste("Yearly change in PC below equilibrium max change value of", eq.md, "at", t_step, i,". Value at equilibrium is ", PC, ".", sep=" "))
          setbreak <- TRUE
        }
      }
      if (setbreak) break
    } # end for loop
    
    colnames(out) <- c("time", "PC", "SCw", "SCs", "ECb", "ECm", "ECs", "CO2")
    
    out <- as.data.frame(out)
    out <- out[1:(floor(i * tstep / tsave)),]
    
  }) # end of with...
  
} # end of model.run

### Model.R ================================================================

### Documentation ==========================================================
# Function calculating the rates of change. Used later in the differential 
# equation solver function.
### ========================================================================

Model <- function(t, initial_state, pars) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  
  with(as.list(c(initial_state, pars)), {
    
    # Calculate the input and forcing at time t
    litter_str <- Approx_litter_str(t)
    litter_met <- Approx_litter_met(t)
    temp       <- Approx_temp(t)
    moist      <- Approx_moist(t)
    
    # Calculate temporally changing variables
    K_D     <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K.D, R)
    K_SM    <- Temp.Resp.Eq(K_SM_ref, temp, T_ref, E_K.SM, R)
    K_EM    <- Temp.Resp.Eq(K_EM_ref, temp, T_ref, E_K.EM, R)
    V_D     <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V.D, R)
    CUE     <- CUE_ref
    Em      <- Temp.Resp.Eq(Em_ref, temp, T_ref, E_Em, R)
    
    ## Diffusion calculations  --------------------------------------
    # Note: for diffusion fluxes, no need to divid by moist and depth to get specific
    # concentrations and multiply again for total since they cancel out.
    if(moist <= Rth) diff <- 0 else diff <- (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5
    diffmod_S <- diff / dist * D_S0
    diffmod_E <- diff / dist * D_E0
    SC.diff <- diffmod_S * (SCw - 0) # concentration at microbe is 0
    EC.diff <- diffmod_E * (ECw - 0) # concentration at substrate is 0

    fc.scale <- min(1, moist / fc)

    
    ## Calculate change rates ---------------------------------------
    
    # Input rate
    F_sl.pc    <- litter_str
    F_ml.scw   <- litter_met
    
    # Decomposition rate
    F_pc.scw   <- F_decomp(PC, EC.diff, V_D, K_D, moist, fc, depth, fc.scale)
    
    # Adsorption/desorption
    if(adsorption) {
      F_scw.scs  <- F_adsorp(SCw, SCs, ECw, ECs, M, ka.s, moist, fc, depth)
      F_scs.scw  <- F_desorp(SCs, kd.s, moist, fc, depth)
      F_ecw.ecs  <- F_adsorp(ECw , ECs, SCw, SCs, M, ka.e, moist, fc, depth)
      F_ecs.ecw  <- F_desorb(ECs, kd.e, moist, fc, depth)
    } else {
      F_scw.scs <- 0
      F_scs.scw <- 0
      F_ecw.ecs <- 0
      F_ecs.ecw <- 0
    }
    
    # Microbial growth, mortality, respiration and enzyme production
    if(microbes) {
      F_scw.mc  <- SC.diff * CUE
      F_scw.co2 <- SC.diff * (1 - CUE)
      F_mc.pc   <- MC * NA # here goes mortality of mc 
      F_mc.ecw  <- MC * NA # here goes enzyme production of mc
      F_scw.pc  <- 0
      F_scw.ecw <- 0
    } else {
      F_scw.mc  <- 0
      F_mc.pc   <- 0
      F_mc.ecw  <- 0
      F_scw.co2 <- SC.diff * (1 - CUE)
      F_scw.pc  <- SC.diff * CUE * (1 - Ep)
      F_scw.ecw <- SC.diff * CUE * Ep
    }
    
    # Enzyme decay
    F_ecw.scw  <- ECw * Em
    
    ## Rate of change calculation for state variables ---------------
    dPC  <- F_sl.pc + F_scw.pc - F_pc.scw
    dSCw <- F_ml.scw + F_pc.scw + F_scs.scw + F_ecw.scw - F_scw.scs - F_scw.mc - F_scw.co2 - F_scw.pc - F_scw.ecw
    dSCs <- F_scw.scs - F_scs.scw
    dECw <- F_ecs.ecw + F_mc.ecw + F_scw.ecw - F_ecw.ecs - F_ecw.scw 
    dECs <- F_ecw.ecs - F_ecs.ecw
    dMC  <- F_scw.mc - F_mc.pc - F_mc.ecw
    CO2  <- F_scw.co2
    
    return(list(c(dPC, dSCw, dSCs, dECw, dECs, dMC, dCO2), c(litter_str, litter_met, temp, moist, diffmod_E, diffmod_S)))
    
  }) # end of with(...
  
} # end of Model

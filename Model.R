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
    K_D     <- Temp.Resp.Eq(K_D_ref , temp, T_ref, E_K.D, R)
    ka.s    <- Temp.Resp.Eq(ka.s.ref, temp, T_ref, E_ka , R)
    kd.s    <- Temp.Resp.Eq(kd.s.ref, temp, T_ref, E_kd , R)
    ka.e    <- Temp.Resp.Eq(ka.e.ref, temp, T_ref, E_ka , R)
    kd.e    <- Temp.Resp.Eq(kd.e.ref, temp, T_ref, E_kd , R)
    V_D     <- Temp.Resp.Eq(V_D_ref , temp, T_ref, E_V.D, R)
    Mm      <- Temp.Resp.Eq(Mm_ref  , temp, T_ref, E_Mm , R)
    Em      <- Temp.Resp.Eq(Em_ref  , temp, T_ref, E_Em , R)
    CUE     <- CUE_ref
    
    ## Diffusion calculations  --------------------------------------
    # Note: for diffusion fluxes, no need to divide by moist and depth to get specific
    # concentrations and multiply again for total since they cancel out.
    if(moist <= Rth) diff <- 0 else diff <- (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5 # reference?
	SC.diff <- D_S0 * (SCw - 0) * diffmod / dist
	EC.diff <- D_E0 * (ECm - ECw) * diffmod / dist

      ### Calculate all fluxes ------
 
    # Input rate
    F_sl.pc    <- litter_str
    F_ml.scw   <- litter_met

    # Decomposition rate
    F_pc.scw   <- F_decomp(PC, ECw, V_D, K_D, moist, fc, depth)
    
    # Adsorption/desorption
    if(flag.ads) {
      F_scw.scs  <- F_adsorp(SCw, SCs, ECs, Md, ka.s, moist, fc, depth)
      F_scs.scw  <- F_desorp(SCs, kd.s, moist, fc)
      F_ecw.ecs  <- F_adsorp(ECw , ECs, SCs, Md, ka.e, moist, fc, depth)
      F_ecs.ecw  <- F_desorb(ECs, kd.e, moist, fc)
    } else {
      F_scw.scs <- 0
      F_scs.scw <- 0
      F_ecw.ecs <- 0
      F_ecs.ecw <- 0
    }
    
    # Microbial growth, mortality, respiration and enzyme production
    if(flag.mic) {
      F_scw.mc  <- SC.diff * CUE
      F_scw.co2 <- SC.diff * (1 - CUE)
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
    
    ## Rate of change calculation for state variables ---------------
    dPC  <- F_sl.pc   + F_scw.pc  - F_pc.scw
    dSCw <- F_ml.scw  + F_pc.scw  + F_scs.scw + F_ecw.scw - F_scw.scs - F_scw.mc - F_scw.co2 - F_scw.pc - F_scw.ecm
    dSCs <- F_scw.scs - F_scs.scw
    dECw <- F_ecs.ecw + F_ecm.ecw - F_ecw.ecs - F_ecw.scw 
    dECm <- F_scw.ecm + F_mc.ecm  - F_ecm.ecw
    dECs <- F_ecw.ecs - F_ecs.ecw
    dMC  <- F_scw.mc  - F_mc.pc   - F_mc.ecm
    dCO2 <- F_scw.co2
    
    return(list(c(dPC, dSCw, dSCs, dECw, dECm, dECs, dMC, dCO2), c(litter_str=litter_str, litter_met=litter_met, temp=temp, moist=moist, diffmod_E=diffmod_E, diffmod_S=diffmod_S)))
    
  }) # end of with(...
  
} # end of Model

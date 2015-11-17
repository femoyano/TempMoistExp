### Model.R ================================================================

### Documentation ==============================================================
# Function calculating the rates of change. Used later in the differential 
# equation solver function.
### ============================================================================

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
    
    if(!enzyme.diff) ECm  <- 0
    
    # Note: for diffusion fluxes, no need to divid by moist and depth to get specific
    # concentrations and multiply again for total since they cancel out.
    if(moist <= Rth) diff <- 0 else diff <- (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5
    diffmod_S <- diff / dist * D_S0
    diffmod_E <- diff / dist * D_E0

    # Calculate change rates
    
    F_sl.pc    <- litter_str
    F_ml.scw   <- litter_met
    
    F_pc.scw   <- F_decomp(PC, ECb, V_D, K_D, moist, fc, depth)
    
    if (adsorption) {
      F_scw.scs  <- F_sorp(SCw, SCs, ECb, ECs, M, K_SM, K_EM, moist, fc, depth)
      F_ecb.ecs  <- F_sorp(ECb, ECs, SCw, SCs, M, K_EM, K_SM, moist, fc, depth)
    } else {
      F_scw.scs <- 0
      F_ecb.ecs <- 0
    }
    
    F_scw.diff <- diffmod_S * (SCw - 0) # concentration at microbe assumed to be 0 
    F_scw.co2  <- F_scw.diff * (1 - CUE)
    F_scw.pc   <- F_scw.diff * CUE * (1 - Ep)
    
    if (enzyme.diff) {
      F_scw.ecb <- 0
      F_scw.ecm <- F_scw.diff * CUE * Ep
      F_ecm.ecb <- diffmod_E * (ECm - ECb)
      F_ecm.scw <- F_e.decay(ECm, Em)
    } else {
      F_scw.ecb <- F_scw.diff * CUE * Ep
      F_scw.ecm <- 0
      F_ecm.ecb <- 0
      F_ecm.scw <- 0
    }
    
    F_ecb.scw  <- F_e.decay(ECb, Em)
    
    dPC  <- F_sl.pc + F_scw.pc - F_pc.scw
    dSCw <- F_ml.scw + F_pc.scw + F_ecb.scw + F_ecm.scw - F_scw.diff
    dSCs <- 
    dECb <- F
    dECm <- F
    dECs <- F
    CO2  <- F
    
  }) # end of with(...
  
} # end of Model

#### Model.R ================================================================

#### Documentation ==========================================================
# Main function running the model.
# This version is for use with deSolve ode function. It calculates and returns
# the state variable rates of change.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ========================================================================

Model_desolve <- function(t, initial_state, pars) { # must be defined as: func <- function(t, y, parms,...) for use with ode
  
  with(as.list(c(initial_state, pars)), {

    # set time used for interpolating input data.
    t_i <- t
    if(spinup) t_i <- t %% end # this causes spinups to repeat the input data
    
    # Calculate the input and forcing at time t
    I_sl  <- Approx_I_sl(t_i)
    I_ml  <- Approx_I_ml(t_i)
    temp  <- Approx_temp(t_i)
    moist <- Approx_moist(t_i)
    
    # Calculate temporally changing variables
    K_D   <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_KD, R)
    k_ads <- Temp.Resp.Eq(k_ads_ref, temp, T_ref, E_ka , R)
    k_des <- Temp.Resp.Eq(k_des_ref, temp, T_ref, E_kd , R)
    V_D   <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_VD, R)
    r_md  <- Temp.Resp.Eq(r_md_ref, temp, T_ref, E_r_md , R)
    r_ed  <- Temp.Resp.Eq(r_ed_ref, temp, T_ref, E_r_ed , R)
    r_mm  <- Temp.Resp.Eq(r_mm_ref, temp, T_ref, E_r_ed , R)
    f_gr  <- f_gr_ref
    fc.mod <- get.fc.mod(moist, fc)
    moist.mod <- get.moist.mod(moist)
    
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
    F_sl.pc    <- I_sl
    F_ml.scw   <- I_ml
    
    # Decomposition rate
    F_pc.scw   <- F_decomp(C_P, C_Ew, V_D, K_D, moist.mod, depth, fc.mod)
    
    # Adsorption/desorption
    if(flag.ads) {
      F_scw.scs  <- F_adsorp(C_D, C_A, Md, k_ads, moist.mod, depth, fc.mod)
      F_scs.scw  <- F_desorp(C_A, k_des, fc.mod)
    } else {
      F_scw.scs <- 0
      F_scs.scw <- 0
    }
    
    # Microbial growth, mortality, respiration and enzyme production
    if(flag.mic) {
      F_scw.mc  <- D_d * (C_D - 0) * f_gr
      F_scw.co2 <- D_d * (C_D - 0) * (1 - f_gr)
      F_mc.pc   <- C_M * r_md
      F_mc.ecm  <- C_M * f_me
      F_mc.co2  <- C_M * f_mm
      F_scw.pc  <- 0
      F_scw.ecm <- 0
    } else {
      F_scw.mc  <- 0
      F_mc.pc   <- 0
      F_mc.ecm  <- 0
      F_scw.co2 <- D_d * (C_D - 0) * (1 - f_gr)
      F_scw.pc  <- D_d * (C_D - 0) * f_gr * (1 - f_de)
      F_scw.ecm <- D_d * (C_D - 0) * f_gr * f_de
    }
    
    F_ecm.ecw  <- D_e * (C_Em - C_Ew)
    
    # Enzyme decay
    F_ecw.scw  <- C_Ew * r_ed
    F_ecm.scw  <- C_Em * r_ed
    
    ## Rate of change calculation for state variables ---------------
    dC_P  <- F_sl.pc   + F_scw.pc  + F_mc.pc   - F_pc.scw
    dC_D <- F_ml.scw  + F_pc.scw  + F_scs.scw + F_ecw.scw + F_ecm.scw -
            F_scw.scs - F_scw.mc - F_scw.co2 - F_scw.pc - F_scw.ecm
    dC_A <- F_scw.scs - F_scs.scw
    dC_Ew <- F_ecm.ecw - F_ecw.scw 
    dC_Em <- F_scw.ecm + F_mc.ecm  - F_ecm.ecw - F_ecm.scw
    dC_M  <- F_scw.mc  - F_mc.pc   - F_mc.ecm - F_mc.co2
    dC_R <- F_scw.co2 + F_mc.co2
    
    return(list(c(dC_P, dC_D, dC_A, dC_Ew, dC_Em, dC_M, dC_R)))
    
  }) # end of with(...
  
} # end of Model

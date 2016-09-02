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
    K_D   <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K, R)
    K_U   <- Temp.Resp.Eq(K_U_ref, temp, T_ref, E_K, R)
    V_D   <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V, R)
    V_U   <- Temp.Resp.Eq(V_U_ref, temp, T_ref, E_V, R)
    r_md  <- Temp.Resp.Eq(r_md_ref, temp, T_ref, E_r_d , R)
    r_ed  <- Temp.Resp.Eq(r_ed_ref, temp, T_ref, E_r_d , R)
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
    F_sl.cp <- I_sl
    F_ml.cd <- I_ml
    
    # Decomposition rate
    F_cp.cd <- Decomp(C_P, C_E, V_D, K_D, moist.mod, depth, fc.mod)
    
    Diff.cd <- D_d * (C_D - 0)  # Calculate the diffusion fluxes
    
    if(flag.mmu) {
      U.cd <- Uptake(Diff.cd, V_U, K_U, moist.mod, depth, fc.mod)  # Calculate the uptake flux    
    } else {
      U.cd <- Diff.cd
    }
    
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
    
    # Enzyme decay
    F_ce.cd <- C_E * r_ed

    ## Rate of change calculation for state variables ---------------
    dC_P <- F_sl.cp + F_cd.cp + F_cm.cp - F_cp.cd
    dC_D <- F_ml.cd + F_cp.cd + F_ca.cd + F_ce.cd - F_cd.ca - F_cd.cm -
            F_cd.cr - F_cd.cp  - F_cd.ce
    dC_E <- F_cd.ce - F_ce.cd
    dC_M <- F_cd.cm - F_cm.cp - F_cm.cr
    dC_R <- F_cd.cr + F_cm.cr
    
    return(list(c(dC_P, dC_D, dC_E, dC_M, dC_R)))
    
  }) # end of with(...
  
} # end of Model

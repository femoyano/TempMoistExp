#### Model.R ================================================================

#### Documentation ==========================================================
# Main function running the model.
# This version is for use with deSolve ode function. It calculates and returns
# the state variable rates of change.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ========================================================================

Model_desolve <- function(t, initial_state, pars) {
  # must be defined as: func <- function(t, y, parms,...) for use with ode

  with(as.list(c(initial_state, pars)), {

    # set time used for interpolating input data.
    t_i <- t
    if (spinup) t_i <- t%%end  # this causes spinups to repeat the input data

    # Calculate the input and forcing at time t
    I_sl <- Approx_I_sl(t_i)
    I_ml <- Approx_I_ml(t_i)
    temp <- Approx_temp(t_i)
    moist <- Approx_moist(t_i)

    # Calculate temporally changing variables
    K_D   <- Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K, R)
    K_U   <- Temp.Resp.Eq(K_U_ref, temp, T_ref, E_K, R)
    V_D   <- Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V, R)
    V_U   <- Temp.Resp.Eq(V_U_ref, temp, T_ref, E_V, R)
    r_md  <- Temp.Resp.Eq(r_md_ref, temp, T_ref, E_m , R)
    r_ed  <- Temp.Resp.Eq(r_ed_ref, temp, T_ref, E_e , R)
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
    
    # Diffusion calculations
    Diff.cd <- D_d * C_D
    Diff.ce <- D_e * C_E

    ### Calculate all fluxes ------
    # Input rate
    F_sl.cp <- I_sl
    F_ml.cd <- I_ml

    # Decomposition rate
    if(dec.fun == "MM") {
      F_cp.cd <- ReactionMM(C_P, C_E, V_D, K_D, depth, moist.mod, fc.mod)
    }
    if(dec.fun == "2nd") {
      F_cp.cd <- Reaction2nd(C_P, C_E, V_D, depth, moist.mod, fc.mod)
    }
    if(dec.fun == "1st") {
      F_cp.cd <- Reaction1st(C_P, V_D, fc.mod)
    }

    # Calculate the uptake flux
    if(upt.fun == "MM") {
      U.cd <- ReactionMM(Diff.cd, C_M, V_U, K_U, depth, moist.mod, fc.mod)
    }
    if(upt.fun == "2nd") {
      U.cd <- Reaction2nd(Diff.cd, C_M, V_U, depth, moist.mod, fc.mod)
    }
    if(upt.fun == "1st") {
      U.cd <- Reaction1st(Diff.cd, V_U, fc.mod)
    }

    # Microbial growth, mortality, respiration and enzyme production
    if(flag.mic) {
      F_cd.cm <- U.cd * f_gr * (1 - f_ue)
      F_cm.cp <- C_M * r_md * (1 - f_mr)
      F_cm.cr <- C_M * r_md * f_mr
      F_cd.cp <- 0
    } else {
      F_cd.cm <- 0
      F_cm.cp <- 0
      F_cm.cr <- 0
      F_cd.cp <- U.cd * f_gr * (1 - f_ue)
    }

    F_em.ce <- D_e * (C_Em - C_E)
    F_cd.cr <- U.cd * (1 - f_gr)
    F_cd.cem <- U.cd * f_gr * f_ue

    # Enzyme decay
    F_ce.cd <- C_E * r_ed
    F_em.cd <- C_Em * r_ed
    
    ## Rate of change calculation for state variables ---------------
    dC_P <- F_sl.cp + F_cd.cp + F_cm.cp - F_cp.cd
    dC_D <- F_ml.cd + F_cp.cd + F_ce.cd + F_em.cd - F_cd.cm -
            F_cd.cr - F_cd.cp  - F_cd.em
    dC_E <- F_em.ce - F_ce.cd
    dC_Em <- F_cd.em - F_em.ce - F_em.cd
    dC_M <- F_cd.cm - F_cm.cp - F_cm.cr
    dC_Rg <- F_cd.cr
    dC_Rm <- F_cm.cr

    return(list(c(dC_P, dC_D, dC_E, dC_Em, dC_M, dC_Rg, dC_Rm),
      C_dec_r = F_cp.cd, temp = temp, moist = moist, D_d = D_d))

  })  # end of with(...

}  # end of Model

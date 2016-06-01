# Convert all rates to model time step

pars[["r_md_ref"]] <- pars[["r_md_ref"]] / hour * tstep
pars[["r_ed_ref"]] <- pars[["r_ed_ref"]] / hour * tstep
pars[["V_D_ref"]]  <- pars[["V_D_ref"]] / hour * tstep
pars[["V_U_ref"]]  <- pars[["V_U_ref"]] / hour * tstep
pars[["D_0"]]  <- pars[["D_0"]] / sec * tstep
# pars[["D_d0"]] <- pars[["D_d0"]] / sec * tstep
# pars[["D_e0"]] <- pars[["D_e0"]] / sec * tstep
pars[["k_ads_ref"]] <- pars[["k_ads_ref"]] / sec * tstep
pars[["k_des_ref"]] <- pars[["k_des_ref"]] / sec * tstep

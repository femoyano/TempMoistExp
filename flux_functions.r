# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase, so C pools are  divided by water
# content to obtain concentrations, then rates are multiplied by water content.

# Functions calculating the fluxes of C.

# Metabolic litter input to LC
F_ml.lc <- function (litter_met) { # the input of litter is prescribed; no calculations are required
  litter_met
}

# Structural litter input to RC
F_sl.rc <- function (litter_struct) { # the input of litter is prescribed; no calculations are required
  litter_struct
}

# Decomposition of LC into SC
F_lc.sc <- function (LC, RC, ECw, V_LD, K_LD, K_RD, theta, E_V.LD, E_K.LD, E_K.RD, ) {
  LC <- LC / theta
  RC <- RC / theta
  EC <- ECw / theta
  V_LD <- temp.fun.()
  
  (V_LD * LC * ECw) / (K_LD * (1 + LC / K_LD + RC / K_RD + ECw / K_LD)) * theta
}

# Decomposition of RC into SC
F_rc.sc <- function (LC, RC, ECw, V_RD, K_LD, K_RD, theta) {
  LC <- LC / theta
  RC <- RC / theta
  EC <- ECw / theta
  (V_RD * RC * EC) / (K_RD * (1 + RC / K_RD + LC / K_LD + EC / K_RD)) * theta
}

# Sorption of EC to mineral surface
F_ecw.ecs <- function (SCw, SCs, ECw, ECs, M, K_SS, K_ES, theta) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  SC <- SC / theta
  EC <- EC / theta
  M <- M / theta
  (EC * M) / (K_ES * (1 + EC / K_ES + SC / K_SS + M / K_ES)) * theta - ECs
}

# Sorption of SC to mineral surface
F_scw.scs <- function (SCw, SCs, ECw, ECs, M, K_SS, K_ES, theta) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  SC <- SC / theta
  EC <- EC / theta
  M <- M / theta
  (SC * M) / (K_SS * (1 + SC / K_SS + EC / K_ES + M / K_SS)) * theta - SCs
}

# Diffusion of SC to microbes
F_scw.scm <- function (SCw, SCm, D_S0, theta, delta) {
  D_S <- D_S0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_S * (SCw / theta - SCm / theta) / delta
}

# Diffusion of EC from microbes
F_ecm.ecw <- function (SCw, SCm, D_E0, theta, delta) {
  D_E <- D_E0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_E * (SCm / theta - SCw / theta) / delta
}

# Mirobes to ECm
F_mc.ecm <- function (MC, E_P) {
  MC * E_P
}

# CO2 production
F_scm_co2 <- function (SCm, MC, t_MC, CUE, theta, V_SC, K_SU) {
  SCm <- SCm / theta
  MC <- MC * t_MC / theta
  U <- (V_SC * SCm * MC) / (K_SU * SCm + MC) * theta
  U * (1-CUE)
}

# SCm to MC
F_scm.mc <- function (SCm, MC, t_MC, CUE, theta, V_SC, K_SU) {
  SCm <- SCm / theta
  MC <- MC * t_MC / theta
  U <- (V_SC * SCm * MC) / (K_SU * SCm + MC) * theta
  U * CUE
}

# Dead microbes to labile carbon pool
F_mc_lc <- function (MC, Mm) {
  MC * Mm * (1 - mcrc_f)
}

# Dead microbes to SC pool
F_mc_sc <- function (MC, Mm) {
  MC * Mm * mcsc_f
}

# Decaying enzymes going to LC pool
F_ec.lc <- function (ECw, Em) { # enzyme decay and flux to SC pool
  ECw * Em
}

# Transfer from / to immobile pool
F_sci.scw <- function (SCw, SCi, dtheta, theta, theta_fc) {
  if (theta < theta_fc) {
    ifelse (dtheta >= 0, dtheta * (SCi / (theta_fc - theta)), dtheta * (SCw / theta))
  } else SCi
}

# Advection flux out
F_scw.adv <- function (SCw, theta, percolation) {
  SCw / theta * percolation
}

# Advection flux in
F_adv.scw <- function (advection_in) { # prescribed
  advection_in
}

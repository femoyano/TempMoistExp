# flux_functions.r 

# Functions calculating the fluxes of C.

# Metabolic litter input
F_ml.lc <- function (litter_met) { # the input of litter is prescribed so no calculations are required
  litter_met
}

# Structural litter input
F_sl.rc <- function (litter_struct) { # the input of litter is prescribed so no calculations are required
  litter_struct
}

# Decomposition of LC C by enzymes
F_lc.sc <- function (LC, RC, ECw, kf_LC,  K_LC, K_RC) {
  (kf_LC * LC * ECw) / (K_LC * (1 + LC / K_LC + RC / K_RC + ECw / K_LC))
}

# Decomposition of RC C by enzymes
F_rc.sc <- function (LC, RC, ECw, kf_RC, K_LC, K_RC) {
  (kf_RC * RC * ECw) / (K_RC * (1 + RC / K_RC + LC / K_LC + ECw / K_RC))
}

# Sorption of enzymes to mineral surface
F_ecw.ecs <- function (SCw, SCs, ECw, ECs, M, K_SC, K_EC) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  (EC * M) / (K_EC * (1 + EC / K_EC + SC / K_SC + M / K_EC)) - ECs
}

# Sorption of SC to mineral surface
F_scw.scs <- function (SCw, SCs, ECw, ECs, M, K_SC, K_EC) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  (SC * M) / (K_SC * (1 + SC / K_SC + EC / K_EC + M / K_SC)) - SCs
}

# Diffusion of SC to microbes
F_scw.scm <- function (SCw, SCm, D_S0, theta, delta) {
  D_S <- D_S0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_S * (SCw / theta - SCm / theta) / delta
}

# Diffusion of enzymes from microbes
F_ecm.ecw <- function (SCw, SCm, D_E0, theta, delta) {
  D_E <- D_E0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_E * (SCm / theta - SCw / theta) / delta
}

# Transfer to disconnected zones. Need to figure out how to consider fc issue.
# F_scw.scd <- function (SCw, dtheta) {
#   theta
#   ifelse (dtheta < 0,  SCw / theta * (-dtheta), SCd  
# }

# Mirobial turnover and transfer to LC
F_mc.ecm <- function (MC, ECm_f) {
  (MC * ECm_f) - ECm
}

# CO2 production
F_scm_co2 <- function (SCm, CUE) {
  psi <- campbell
  u <- 1.06 * 0.185 * psi - 1.37
   SCm * u * (1-CUE)
}

# Dead microbes to labile carbon pool
F_mc_lc <- function (MC, Mm) {
  MC * Mm * (1 - mcrc_f)
}

# Dead microbes to recalcitrant carbon pool
F_mc_rc <- function (MC, Mm) {
  MC * Mm * mcrc_f
}

# Decaying enzymes going to LC pool
F_ec.lc <- function (ECw, Em) { # the flux from the enzyme pool to dissolved organic matter by enzyme breakdown
  ECw * Em  
}
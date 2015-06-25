# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase, so C pools are  divided by water
# content to obtain concentrations, then rates are multiplied by water content.

# Functions calculating the fluxes of C.

# Metabolic litter input
F_ml.lc <- function (litter_met) { # the input of litter is prescribed; no calculations are required
  litter_met
}

# Structural litter input
F_sl.rc <- function (litter_struct) { # the input of litter is prescribed; no calculations are required
  litter_struct
}

# Decomposition of LC by enzymes
F_lc.sc <- function (LC, RC, ECw, kf_LC, K_LC, K_RC, theta, ) {
  LC <- LC / theta
  RC <- RC / theta
  EC <- ECw / theta
  kf_LC <- temp.fun.()
  (kf_LC * LC * ECw) / (K_LC * (1 + LC / K_LC + RC / K_RC + ECw / K_LC)) * theta
}

# Decomposition of RC by enzymes
F_rc.sc <- function (LC, RC, ECw, kf_RC, K_LC, K_RC, theta) {
  LC <- LC / theta
  RC <- RC / theta
  EC <- ECw / theta
  (kf_RC * RC * EC) / (K_RC * (1 + RC / K_RC + LC / K_LC + EC / K_RC)) * theta
}

# Sorption of enzymes to mineral surface
F_ecw.ecs <- function (SCw, SCs, ECw, ECs, M, K_SC, K_EC, theta) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  SC <- SC / theta
  EC <- EC / theta
  M <- M / theta
  (EC * M) / (K_EC * (1 + EC / K_EC + SC / K_SC + M / K_EC)) * theta - ECs
}

# Sorption of SC to mineral surface
F_scw.scs <- function (SCw, SCs, ECw, ECs, M, K_SC, K_EC, theta) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  SC <- SC / theta
  EC <- EC / theta
  M <- M / theta
  (SC * M) / (K_SC * (1 + SC / K_SC + EC / K_EC + M / K_SC)) * theta - SCs
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

# Mirobes to LC
F_mc.ecm <- function (MC, ECm_f) {
  (MC * ECm_f) - ECm
}

# CO2 production
F_scm_co2 <- function (SCm, MC, t_MC, CUE, theta, kf_SC, K_SC) {
  SCm <- SCm / theta
  MC <- MC * t_MC / theta
  U <- (kf_SC * SCm * MC) / (K_SC * SCm + MC) * theta
  U * (1-CUE)
}

# SCm to MC
F_scm.mc <- function (SCm, MC, t_MC, CUE, theta, kf_SC, K_SC) {
  SCm <- SCm / theta
  MC <- MC * t_MC / theta
  U <- (kf_SC * SCm * MC) / (K_SC * SCm + MC) * theta
  U * CUE
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

# flux_functions.r 

# Functions calculating the change in each state variable are defined here.

F_ml.lc <- function (litter_met) { # the input of litter is prescribed so no calculations are required
  litter_met
}

F_sl.rc <- function (litter_struct) { # the input of litter is prescribed so no calculations are required
  litter_struct
}

F_ec.lc <- function (ECw, Em) { # the flux from the enzyme pool to dissolved organic matter by enzyme breakdown
  ECw * Em  
}

F_lc.sc <- function (LC, RC, ECw, kf_LC,  K_LC, K_RC) {
  (kf_LC * LC * ECw) / (K_LC * (1 + LC / K_LC + RC / K_RC + ECw / K_LC))
}

F_rc.sc <- function (LC, RC, ECw, kf_RC, K_LC, K_RC) {
  (kf_RC * RC * ECw) / (K_RC * (1 + RC / K_RC + LC / K_LC + ECw / K_RC))
}

F_ecw.ecs <- function (SCw, SCs, ECw, ECs, M, K_SC, K_EC) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  (EC * M) / (K_EC * (1 + EC / K_EC + SC / K_SC + M / K_EC)) - ECs
}

F_scw.scs <- function (SCw, SCs, ECw, ECs, M, K_SC, K_EC) {
  SC <- SCw + SCs
  EC <- ECw + ECs
  (SC * M) / (K_SC * (1 + SC / K_SC + EC / K_EC + M / K_SC)) - SCs
}

F_scw.scm <- function (SCw, SCm, D_S, theta, delta) {
  D_S <- D_S0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_S * (SCw / theta - SCm / theta) / delta
}

F_ecw.ecm <- function (SCw, SCm, D_E, theta, delta) {
  D_E <- D_E0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_E * (SCw / theta - SCm / theta) / delta
}


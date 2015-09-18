# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per cm^-3 water
# so soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.

# Functions calculating the fluxes of C.

# Decomposition flux
F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
  PC <- PC / depth * min(1, moist / fc) # scaled with max at fc
  EC <- EC / (moist * depth) # concetration in water phase
  F <- (V * EC * PC) / (K + PC) * depth
  ifelse(F > PC, PC, F)
}

# Enzymes decay
F_ec.sc <- function (EC, Em) {
  F <- EC * Em
  ifelse(F > EC, EC, F)
}

# Sorption to mineral surface
F_sorp <- function (C1b, C1s, C2b, C2s, M, K_1, K_2, moist, fc, depth) {
  mmod <- min(1, moist / fc) # for scaling M and Cs from 0-1 between 0 and fc
  C1 <- (C1b + C1s) / (depth * moist)
  C2 <- (C2b + C2s) / (depth * moist)
  M <- M * mmod
  F <- (C1 * M) / (K_1 * (1 + C1 / K_1 + C2 / K_2 + M / K_1)) * depth - (C1s * mmod)
  if(F > C1b) C1b else if((-1 * F) > C1s) C1s else F
}

# ==============================================================================
# Temperature responses after to Tang and Riley 2014 (supplementary information)

# Temperature response for equilibrium reactions = Arrhenius (for K values)
Temp.Resp.Eq <- function(k_ref, T, T_ref, E, R) {
  k_ref * exp(-E/R * (1/T-1/T_ref))
}

# Temperature response for non-equilibrium reactions (for V values)
Temp.Resp.NonEq <- function(k_ref, T, T_ref, E, R) {
  k_ref * T/T_ref * exp(-E/R * (1/T-1/T_ref))
}


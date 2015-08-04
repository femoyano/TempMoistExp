# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per cm^-3 water
# so soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.

# Functions calculating the fluxes of C.

# Litter input
F_litter <- function (litter_flux) { # the input of litter is prescribed; no calculations are required
  F <- litter_flux
}

# Decomposition flux
F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
  PC <- PC / depth * min(1, moist / fc) # scaled with max at fc
  EC <- EC / (moist * depth) # concetration in water phase
  F <- (V * EC * PC) / (K + PC) * depth
  ifelse(F > PC, PC, F)
}

# # Microbial C uptake
# F_uptake <- function (SC, V, K, moist, fc, depth) {
#   SC <- SC / (moist * depth) # concetration in water phase
#   F <- (V * SC) / (K + SC) * (moist * depth)
#   ifelse(F > SC, SC, F)
# }

# # Microbe to enzyme
# F_mc.ecm <- function (MC, Ep, Mm) {
#   F <- (MC - (MC * Mm)) * Ep
#   ifelse(F > MC, MC, F)
# }

# # Microbe death
# F_mc.pcscw <- function (MC, Mm) {
#   F <- MC * Mm
#   ifelse(F > MC, MC, F)
# }

# Enzymes decay
F_ecb.scw <- function (EC, Em) {
  F <- EC * Em
  ifelse(F > EC, EC, F)
}

# Diffusion flux
# Here dividing by moist and depth for specific concentrations and multiplying 
# again for total cancels out, so they are left out.
F_diffusion <- function (C1, C2, D_0, moist, dist, ps, Rth) {
  if (moist <= Rth) return(0)
  D <- D_0 * (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5
  F <- D * (C1 - C2) / dist
  ifelse(abs(F) > abs((C1 - C2) / 2), (C1 - C2) / 2, F)
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


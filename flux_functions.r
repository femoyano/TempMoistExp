# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per cm^-3 water
# so soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.

# Functions calculating the fluxes of C.

# Litter input
F_litter <- function (litter_flux) { # the input of litter is prescribed; no calculations are required
  litter_flux
}

# Decomposition flux
F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
  PC <- PC / depth * min(1, moist / fc) # scaled with max at fc
  EC <- EC / (moist * depth) # concetration in water phase
  (V * EC * PC) / (K + PC) * depth
}

# Microbial C uptake
F_uptake <- function (SC, MC, V, K, moist, fc, depth) {
  SC <- SC / (moist * depth) # concetration in water phase
  MC <- MC / depth * min(1, moist / fc) # scaled with max at fc
  (V * SC * MC) / (K + SC) * (moist * depth)
}

# Microbe to enzyme
F_mc.ecm <- function (MC, E_p, Mm) {
  (MC - (MC * Mm)) * E_p
}

# Microbe death
F_mc.pcscb <- function (MC, Mm) {
  MC * Mm
}

# Enzymes decay
F_ecb.scb <- function (EC, Em) {
  EC * Em
}

# Diffusion flux
# Here dividing by moist and depth for specific concentrations and multiplying 
# again for total cancels out, so they are left out.
F_diffusion <- function (C1, C2, D_0, moist, dist, phi, Rth) {
  if (moist <= Rth) return(0)
  D <- D_0 * (phi - Rth)^1.5 * ((moist - Rth)/(phi - Rth))^2.5
  D * (C1 - C2) / dist 
}

# Sorption to mineral surface
F_sorp <- function (C1b, C1s, C2b, C2s, M, K_C1, K_C2, moist, fc, depth) {
  C1 <- (C1b + C1s) / (depth * moist)
  C2 <- (C2b + C2s) / (depth * moist)
  M <- M / depth * min(1, moist / fc)
  (C1 * M) / (K_C1 * (1 + C1 / K_C1 + C2 / K_C2 + M / K_C1)) * (depth * moist) - C1s
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


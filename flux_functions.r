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
F_decomp <- function (C, E, V, K, moist, depth) {
  C <- C / depth # * moist # to test moist here
  E <- E / (moist * depth) # depth
  (V * E * C) / (K + C) * depth
}

# Microbial C uptake
F_uptake <- function (C, M, V, K, moist, depth) {
  C <- C / (moist * depth)
  M <- M / (moist * depth)
  (V * C * M) / (K + C) * (moist * depth)
}

# Microbe to enzyme
F_mc.ecm <- function (MC, E_p, Mm) {
  (MC - (MC * Mm)) * E_p
}

# Microbe to SC
F_mc.scb <- function (MC, Mm, mcpc_f) {
  MC * Mm * (1- mcpc_f)
}

# Microbe to PC
F_mc.pc <- function (MC, Mm, mcpc_f) {
  MC * Mm * mcpc_f
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


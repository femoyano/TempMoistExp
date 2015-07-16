# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per cm^-3 water
# so C pools are  divided by water times cm^3 in 1m^3 water.
# content to obtain concentrations, then rates are multiplied by water content.

# Functions calculating the fluxes of C.

# Litter input
F_litter <- function (litter_flux) { # the input of litter is prescribed; no calculations are required
  litter_flux
}

# Decomposition flux
F_decomp <- function (C, E, V, K) {
  (V * C * E) / (K + C + E)
}

# Microbial C uptake
F_uptake <- function (SC, MC, V_U, K_U) {
  (V_U * SC * MC) / (K_U + SC)
}

# Microbe to enzyme
F_mc.ec <- function (MC, E_P, Mm) {
  (MC - (MC * Mm)) * E_P
}

# Microbe to SC
F_mc.sc <- function (MC, Mm, mcpc_f) {
  MC * Mm * (1- mcpc_f)
}

# Microbe to PC
F_mc.pc <- function (MC, Mm, mcpc_f) {
  MC * Mm * mcpc_f
}

# Enzymes decay
F_ec.sc <- function (EC, Em) {
  EC * Em
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


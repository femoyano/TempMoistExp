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
F_mc.sc <- function (MC, Mm, mcsc_f) {
  MC * Mm * mcsc_f
}

# Microbe to PC
F_mc.pc <- function (MC, Mm, mcsc_f) {
  MC * Mm * (1 - mcsc_f)
}

# Enzymes decay
F_ec.sc <- function (EC, Em) {
  EC * Em
}

# ==============================================================================
# Temperature responses after to Tang and Riley 2014 (supplementary information)

# Temperature response for equilibrium reactions (for K values)
Temp.Resp.Eq <- function(K, T, T0, E, R) {
  K * exp(-E/R * (1/T-1/T0))
}

# Temperature response for non-equilibrium reactions (for V values)
Temp.Resp.NonEq <- function(K, T, T0, E, R) {
  K * T/T0 * exp(-E/R * (1/T-1/T0))
}

# ==============================================================================
# Function to check for equilibirum conditions
# Calculates the absolute change in C between the last two years of simulation
CheckEquil <- function(PC, i, delt, eq.md) {
  y1 <- PC[(i-12/delt+1):i]
  y2 <- PC[(i-24/delt+1):(i-12/delt)]
  x <- abs(mean(y2) - mean(y1))
  if(is.na(x)) browser()
  ifelse(x <= (eq.md), TRUE, FALSE)
}


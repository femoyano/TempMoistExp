# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase, so C pools are  divided by water
# content to obtain concentrations, then rates are multiplied by water content.

# Functions calculating the fluxes of C.

# Litter input
F_litter <- function (litter_flux) { # the input of litter is prescribed; no calculations are required
  litter_flux
}

# Decomposition flux
F_decomp <- function (S, E, V, K, theta, cm3) {
  S <- S / (theta * cm3)
  E <- E / (theta * cm3)
  (V * S * E) / (K + S + E) * (theta * cm3)
}

# Sorption to mineral surface
F_sorp <- function (S1w, S1s, S2w, S2s, M, K_M1, K_M2, theta, cm3) {
  S1 <- S1w + S1s
  S2 <- S2w + S2s
  S1 <- S1 / (theta * cm3)
  S2 <- S2 / (theta * cm3)
  M <- M / (theta * cm3)
  (S1 * M) / (K_M1 * (1 + S1 / K_M1 + M / K_M1 + S2 / K_M2)) * (theta * cm3) - S1s
}

# Diffusion flux
F_diff <- function (Sw, Sm, D_S0, theta_s, dist, phi, Rth) {
  if (theta_s <= Rth) return(0)
  D_S <- D_S0 * (phi - Rth)^1.5 * ((theta_s - Rth)/(phi - Rth))^2.5
  D_S * (Sw - Sm) / dist # dividing by theta for specific concentrations and multiplying again for total cancels theta out
}

# Microbial C uptake (first order)
F_uptake1 <- function(SC, theta, V_U1, K_U1) {
  SC <- SC / (theta * cm3)
  (V_U1 * SC) / (K_U1 + SC) * (theta * cm3)
}

# Microbial C uptake (second order)
F_uptake2 <- function (SC, MC, t_M, theta, V_U2, K_U2) {
  SC <- SC / (theta * cm3)
  MC <- MC * t_MC / (theta * cm3)
  (V_U2 * SC * MC) / (K_U2 + SCm + MC) * (theta * cm3)
}

# Microbes enzyme production
F_mc.ecm <- function (MC, E_P) {
  MC * E_P
}

# Dead microbes
F_mc.lc <- function (MC, Mm) {
  MC * Mm
}

# Decaying enzymes
F_ecw.scw <- function (ECw, Em) {
  ECw * Em
}

# Transfer from / to immobile pool
F_scw.sci <- function (SCw, SCi, theta_d, theta, theta_fc) {
  if (theta < theta_fc) {
    ifelse (theta_d >= 0, max(-theta_d * (SCi / (theta_fc - theta)), -SCi), -theta_d * (SCw / theta))
  } else -SCi
}

# Advection flux out
F_scw.adv <- function (SCw, theta, percolation) {
  SCw / theta * percolation
}

# Advection flux in
F_adv.scw <- function (advection_in) { # prescribed
  advection_in
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
CheckEquil <- function(LC, RC, i, eq.mpd) {
  y1 <- LC[(i-12/delt+1):i] + RC[(i-12/delt+1):i]
  y2 <- LC[(i-24/delt+1):(i-12/delt)] + RC[(i-24/delt+1):(i-12/delt)]
  x <- abs((mean(y1) / mean(y2)) - 1)
  ifelse(x <= (eq.mpd/100), TRUE, FALSE)
}


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
F_decomp <- function (C, E, V, K, theta, cm3) {
  C <- C / (theta * cm3)
  E <- E / (theta * cm3)
  D <- (V * C * E) / (K + C + E) * (theta * cm3)
  ifelse(D > C, C, D) # max decomp is size of C, so C cannot become negative
}

# Sorption to mineral surface
F_sorp <- function (SCw, SCs, Ew, Es, M, K_M1, K_M2, theta, cm3) {
  SC <- SCw + SCs
  E <- Ew + Es
  SC <- SC / (theta * cm3)
  E <- E / (theta * cm3)
  M <- M / (theta * cm3)
  (SC * M) / (K_M1 * (1 + SC / K_M1 + M / K_M1 + E / K_M2)) * (theta * cm3) - SCs
}

# Diffusion flux
F_diff <- function (Sw, Sm, D_S0, theta_s, dist, phi, Rth) {
  if (theta_s <= Rth) return(0)
  D_S <- D_S0 * (phi - Rth)^1.5 * ((theta_s - Rth)/(phi - Rth))^2.5
  D_S * (Sw - Sm) / dist # dividing by theta for specific concentrations and multiplying again for total cancels theta out
}

# Microbial C uptake
F_uptake <- function (SC, MC, theta, V_U, K_U, cm3) {
  SC <- SC / (theta * cm3)
  MC <- MC / (theta * cm3)
  U <- (V_U * SC * MC) / (K_U + SC + MC) * (theta * cm3)
  ifelse(U > SC, SC, U) # max uptake is size of SC, so SC cannot become negative
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
CheckEquil <- function(PC, i, eq.mpd) {
  y1 <- PC[(i-12/delt+1):i]
  y2 <- PC[(i-24/delt+1):(i-12/delt)]
  x <- abs((mean(y1) / mean(y2)) - 1)
  ifelse(x <= (eq.mpd/100), TRUE, FALSE)
}


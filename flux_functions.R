# flux_functions.r 

#### Documentation ============================================================
# Note: chemical reactions occur in the water phase and can calulated per unit volume.
# If this option is on, soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

## Functions that get moisture modifiers depending on the options ----
if(flag.fcs) { get.fc.mod <- function(moist, fc) min(1, moist / fc) } else { 
  get.fc.mod <- function(moist, fc) 1 }

if(flag.sew) { get.moist.mod <- function(moist) moist } else {
  get.moist.mod <- function(moist) 1 }

## Functions to calculate diffusion depending on options -----
if(diff.fun == "hama") {
  get.D_sm <- function(moist, ps, Rth) if(moist <= Rth) D_sm <- 0 else D_sm <- (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5
} else if (diff.fun == "cubic") {
  get.D_sm <- function(moist, ps, Rth) D_sm <- moist^3 
  } else stop ("Wrong diff.fun value?")

if(flag.dte) {
  get.D_tm <- function(temp, T_ref) temp^8/T_ref^8
  } else get.D_tm <- function(temp, T_ref) 1
  
if(flag.dce) {
  # non-linear or linear response
  if(dce.fun == "exp") {
    get.D_cm <- function(C_P, C_ref, C_max) C_P^(-1/3) / C_ref^(-1/3) 
    } else if(dce.fun == "lin") {
    get.D_cm <- function(C_P, C_ref, C_max) (C_P-C_max) / (C_ref-C_max) 
    } else stop("Wrong dce.fun value?")
} else get.D_cm <- function(C_P, C_ref, C_max) 1

##  Decomposition flux ---------
Decomp <- function (C_P, C_E, V_D, K_D, moist.mod, depth, fc.mod) {
  C_P <- C_P / depth * fc.mod
  C_E <- C_E / (moist.mod * depth)
  F <- (V_D * C_E * C_P) / (K_D + C_P) * depth
}

##  Uptake flux ---------
Uptake <- function (S, M, V_U, K_U, moist.mod, depth) {
  M <- M / depth * fc.mod
  S <- S / (depth * moist.mod)
  F_U <- (V_U * S * M) / (K_U + S) * depth
}

# ==============================================================================
# Temperature responses after Tang and Riley 2014 (supplementary information)

# Temperature response for equilibrium reactions = Arrhenius (for K values)
Temp.Resp.Eq <- function(k_ref, T, T_ref, E, R) {
  k_ref * exp(-E/R * (1/T-1/T_ref))
}

# Temperature response for non-equilibrium reactions (for V values)
Temp.Resp.NonEq <- function(k_ref, T, T_ref, E, R) {
  k_ref * T/T_ref * exp(-E/R * (1/T-1/T_ref))
}


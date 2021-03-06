# flux_functions.r

#### Documentation
#### ============================================================
#### Note: chemical reactions occur in the water phase and can
#### calulated per unit volume.  If this option is on, soluble C
#### pools are divided by relative water content to obtain
#### concentrations. Total flux is obtained by then multiplying
#### by the volume where the reaction occurs.  author(s):
#### Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

## Functions that get moisture modifiers depending on the options ----
if (flag_fcs) {
  get_fc_mod <- function(moist, fc) min(1, moist/fc)
} else {
  get_fc_mod <- function(moist, fc) 1
}

if (flag_sew) {
  get_moist_mod <- function(moist) moist
} else {
  get_moist_mod <- function(moist) 1
}

## Functions to calculate diffusion depending on options -----
if (diff_fun == "hama") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) {
    if (moist <= Rth) {D_sm <- 0} else
     D_sm <- (ps - Rth)^p1 * ((moist - Rth) / (ps - Rth))^p2 # p1=1.5, p2=2.5
  }
}
if (diff_fun == "archie") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- ps^p1 * (moist/ps)^p2  # p1=1.3-2.25, p2=2-2.5
}
if (diff_fun == "power") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- moist^p1  # p1=3
}
if (diff_fun == "MQ") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- moist^p1 / ps^p2 # p1=3.33, p2=2
}
if (diff_fun == "PC") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- p1*moist^p2  # p1=2.8, p2=3
}
if (diff_fun == "sade") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- p1*(moist/ps)^p2  # p1=0.73, p2=1.98
}
if (diff_fun == "oles1") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) {
    if (moist < 0.022*b) {D_sm <- 0} else
    D_sm <- p1 * moist * (moist - 0.022 * b) / (ps - 0.022 * b) # p1=0.45
  }
}
if (diff_fun == "oles2") {
  get_D_sm <- function(moist, ps, Rth, b, p1, p2) {
    D_sm <- p1 * moist * (moist / ps)^(p2*b) # p1=0.45, p2=0.3
  }
}

## Other factors affectign diffusion diffusion -----
if (flag_dte) {
  get_D_tm <- function(temp, T_ref) temp^8/T_ref^8
} else get_D_tm <- function(temp, T_ref) 1

if (flag_dce) {
  # non-linear or linear response
  if (dce_fun == "exp") {
    get_D_cm <- function(C_P, C_ref, C_max) C_P^(-1/3)/C_ref^(-1/3)
  } else if (dce_fun == "lin") {
    get_D_cm <- function(C_P, C_ref, C_max) (C_P - C_max)/(C_ref - 
      C_max)
  } else stop("Wrong dce_fun value?")
} else get_D_cm <- function(C_P, C_ref, C_max) 1

## Reaction kinetics ---------
ReactionMM <- function(S, E, V, K, depth, moist.mod, fc.mod) {
  S <- S/(depth * moist.mod)
  E <- E/(depth * moist.mod)
  Flux <- (V * E * S)/(K + S) * depth * fc.mod
}

Reaction2nd <- function(S, E, V, depth, moist.mod, fc.mod) {
  S <- S/(depth * moist.mod)
  E <- E/(depth * moist.mod)
  Flux <- (V * S * E) * depth * fc.mod
}

Reaction1st <- function(S, V, fc.mod) {
  Flux <- V * S * fc.mod
}

# ==============================================================================
# Temperature responses after Tang and Riley 2014
# (supplementary information)

# Temperature response for equilibrium reactions = Arrhenius
# (for K values)
TempRespEq <- function(k_ref, T, T_ref, E, R) {
  k_ref * exp(-E/R * (1/T - 1/T_ref))
}

# Temperature response for non-equilibrium reactions (for V
# values)
TempRespNonEq <- function(k_ref, T, T_ref, E, R) {
  k_ref * T/T_ref * exp(-E/R * (1/T - 1/T_ref))
}


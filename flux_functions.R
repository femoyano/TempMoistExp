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
if (flag.fcs) {
  get.fc.mod <- function(moist, fc) min(1, moist/fc)
} else {
  get.fc.mod <- function(moist, fc) 1
}

if (flag.sew) {
  get.moist.mod <- function(moist) moist
} else {
  get.moist.mod <- function(moist) 1
}

## Functions to calculate diffusion depending on options -----
if (diff.fun == "hama") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) {
    if (moist <= Rth) {D_sm <- 0} else
     D_sm <- (ps - Rth)^p1 * ((moist - Rth) / (ps - Rth))^p2 # p1=1.5, p2=2.5
  }
}
if (diff.fun == "oles1") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) {
    if (moist < 0.022*b) {D_sm <- 0} else
    D_sm <- p1 * moist * (moist - 0.022 * b) / (ps - 0.022 * b) # p1=0.45
  }
}
if (diff.fun == "oles2") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) {
    D_sm <- p1 * moist * (moist / ps)^(p2*b) # p1=0.45, p2=0.3
  }
}
if (diff.fun == "cubic") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- moist^p1  # p1=3
}
if (diff.fun == "MQ") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- moist^p1 / ps^p2 # p1=3.33, p2=2
}
if (diff.fun == "PC") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- p1*moist^p2  # p1=2.8, p2=3
}
if (diff.fun == "sade") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- p1*(moist/ps)^p2  # p1=0.73, p2=1.98
}
if (diff.fun == "archie") {
  get.D_sm <- function(moist, ps, Rth, b, p1, p2) D_sm <- ps^p1 * (moist/ps)^p2  # p1=1.3-2.25, p2=2-2.5
}


## Other factors affectign diffusion diffusion -----
if (flag.dte) {
  get.D_tm <- function(temp, T_ref) temp^8/T_ref^8
} else get.D_tm <- function(temp, T_ref) 1

if (flag.dce) {
  # non-linear or linear response
  if (dce.fun == "exp") {
    get.D_cm <- function(C_P, C_ref, C_max) C_P^(-1/3)/C_ref^(-1/3)
  } else if (dce.fun == "lin") {
    get.D_cm <- function(C_P, C_ref, C_max) (C_P - C_max)/(C_ref - 
      C_max)
  } else stop("Wrong dce.fun value?")
} else get.D_cm <- function(C_P, C_ref, C_max) 1

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
Temp.Resp.Eq <- function(k_ref, T, T_ref, E, R) {
  k_ref * exp(-E/R * (1/T - 1/T_ref))
}

# Temperature response for non-equilibrium reactions (for V
# values)
Temp.Resp.NonEq <- function(k_ref, T, T_ref, E, R) {
  k_ref * T/T_ref * exp(-E/R * (1/T - 1/T_ref))
}


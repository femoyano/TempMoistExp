# flux_functions.r 

#### Documentation ============================================================
# Note: chemical reactions occur in the water phase and are calulated per unit volume
# so soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

# Functions calculating the fluxes of C.

##  Decomposition flux ---------
# The function will depend on the options (flags) chosen

if (!flag.sew & !flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / depth
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(!flag.sew & flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / depth * pc.mod
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
}  else if(flag.sew & flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / depth * pc.mod
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(flag.sew & !flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / depth
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} 

## Adsorption to mineral surface -------------------------
# The function will depend on the options (flags) chosen and
# ligand(L)/receptor(M) kinetics used (https://en.wikipedia.org/wiki/Binding_constant)
# Md stands for density of mineral adsorption site (so is not corrected for depth)
# Lw and La are ligands in water or adsorbed, respectively.
# Mmod is used for scaling M and La from 0-1 between 0 and fc

if(flag.fcs & flag.sew) {
  F_adsorp <- function (Lw, La, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / (depth * moist)
    M <- (Md - La / depth) * mmod
    return( (L * M * k) * depth )
  }
  F_desorp <- function (La, k, moist, fc) {
    mmod <- min(1, moist / fc)
    L <- La * mmod
    return(L * k)
  }
} else if(flag.fcs & !flag.sew) {
  F_adsorp <- function (Lw, La, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / depth
    M <- (Md - La / depth) * mmod
    return( (L * M * k) * depth )
  }
  F_desorp <- function (La, k, moist, fc) {
    mmod <- min(1, moist / fc)
    L <- La * mmod
    return(L * k)
  }
} else if(!flag.fcs & flag.sew) {
  F_adsorp <- function (Lw, La, Md, k, moist, fc, depth) {
    L <- Lw / (depth * moist)
    M <- Md - La / depth
    return( (L * M * k) * depth )
  }
  F_desorp <- function (La, k, moist, fc) {
    L <- La
    return(L * k)
  }
} else if(!flag.fcs & !flag.sew) {
  F_adsorp <- function (Lw, La, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / (depth)
    M <- Md - La / depth
    return( (L * M * k) * depth  )
  }
  F_desorp <- function (La, k, moist, fc) {
    L <- La
    return(L * k)
  }
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


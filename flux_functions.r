# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per unit volume
# so soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.

# Functions calculating the fluxes of C.

##  Decomposition flux ---------
# The function will depend on the options (flags) chosen
if(flag.pcw & !flag.sew) stop("If flag.pcw is TRUE, flag.sew must also be TRUE")

if(flag.pcw & flag.sew & flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / (moist * depth) * pc.mod
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * (moist * depth)
  }
} else if(flag.pcw & flag.sew & !flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / (moist * depth)
    EC <- EC / (moist * depth)  
    F <- (V * EC * PC) / (K + PC) * (moist * depth)
  }
} else if (!flag.pcw & !flag.sew & !flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / depth
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(!flag.pcw & !flag.sew & flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / depth * pc.mod
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
}  else if(!flag.pcw & flag.sew & flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / depth * pc.mod
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(!flag.pcw & flag.sew & !flag.fcs) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / depth
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} 

## Sorption to mineral surface -------------------------
# The function will depend on the options (flags) chosen
# ligand(L)/receptor(M) kinetics used (https://en.wikipedia.org/wiki/Binding_constant)
# Md stands for density of mineral adsorption site (so is not corrected for depth)
# Lw and Ls are ligands in water or adsorbed, respectively.
# Mmod is used for scaling M and Ls from 0-1 between 0 and fc

if(flag.fcs & flag.sew) {
  F_adsorp <- function (Lw, Ls1, Ls2, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / (depth * moist)
    M <- (Md - (Ls1 + Ls2)) * mmod
    return( (L * M * k) * depth )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    mmod <- min(1, moist / fc)
    L <- Ls * mmod
    return(L * k)
  }
} else if(flag.fcs & !flag.sew) {
  F_adsorp <- function (Lw, Ls1, Ls2, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / depth
    M <- (Md - (Ls1 + Ls2)) * mmod
    return( (L * M * k) * depth )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    mmod <- min(1, moist / fc)
    L <- Ls * mmod
    return(L * k)
  }
} else if(!flag.fcs & flag.sew) {
  F_adsorp <- function (Lw, Ls1, Ls2, Md, k, moist, fc, depth) {
    L <- Lw / (depth * moist)
    M <- Md - (Ls1 + Ls2)
    return( (L * M * k) * depth )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    L <- Ls
    return(L * k)
  }
} else if(!flag.fcs & !flag.sew) {
  F_adsorp <- function (Lw, Ls1, Ls2, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / (depth)
    M <- Md - (Ls1 + Ls2)
    return( (L * M * k) * depth  )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    L <- Ls
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


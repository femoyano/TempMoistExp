# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per unit volume
# so soluble C pools are divided by relative water content to obtain 
# concentrations. Total flux is obtained by then multiplying by the volume
# where the reaction occurs.

# Functions calculating the fluxes of C.

##  Decomposition flux ---------
# The function will depend on the options (flags) chosen
if(pc.conc & ec.conc & h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / (moist * depth) * pc.mod
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(pc.conc & ec.conc & !h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / (moist * depth)
    EC <- EC / (moist * depth)  
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(pc.conc & !ec.conc & !h2o.scale){
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / (moist * depth)
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if (!pc.conc & !ec.conc & !h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / depth
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(!pc.conc & !ec.conc & h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / depth * pc.mod
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
}  else if(pc.conc & !ec.conc & h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / (moist * depth) * pc.mod
    EC <- EC / depth
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(!pc.conc & ec.conc & h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    pc.mod <- min(1, moist / fc)
    PC <- PC / depth * pc.mod
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} else if(!pc.conc & ec.conc & !h2o.scale) {
  F_decomp <- function (PC, EC, V, K, moist, fc, depth) {
    PC <- PC / depth
    EC <- EC / (moist * depth)
    F <- (V * EC * PC) / (K + PC) * depth
  }
} 

## Sorption to mineral surface -------------------------
# The function will depend on the options (flags) chosen
# ligand/receptor kinetics used (https://en.wikipedia.org/wiki/Binding_constant)
# Md stands for mineral adsorption site density.
# Lw and Ls are ligands in water or adsorbed.
# Mmod is used for scaling M and Ls from 0-1 between 0 and fc

if(h2o.scale & ec.conc) {
  F_adsorp <- function (Lw, L1s, L2s, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / (depth * moist)
    M <- (Md - (L1s + L2s)) * mmod
    return( (L * M * k) * depth )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    mmod <- min(1, moist / fc)
    L <- Ls * mmod
    return(L * k)
  }
} else if(h2o.scale & !ec.conc) {
  F_adsorp <- function (Lw, L1s, L2s, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / depth
    M <- (Md - (L1s + L2s)) * mmod
    return( (L * M * k) * depth )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    mmod <- min(1, moist / fc)
    L <- Ls * mmod
    return(L * k)
  }
} else if(!h2o.scale & ec.conc) {
  F_adsorp <- function (Lw, L1s, L2s, Md, k, moist, fc, depth) {
    L <- Lw / (depth * moist)
    M <- Md - (L1s + L2s)
    return( (L * M * k) * depth )
  }
  F_desorp <- function (Ls, k, moist, fc) {
    L <- Ls
    return(L * k)
  }
} else if(!h2o.scale & !ec.conc) {
  F_adsorp <- function (Lw, L1s, L2s, Md, k, moist, fc, depth) {
    mmod <- min(1, moist / fc)
    L <- Lw / (depth)
    M <- Md - (L1s + L2s)
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


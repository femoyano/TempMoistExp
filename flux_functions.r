# flux_functions.r 

# Documentation
# Note: chemical reactions occur in the water phase and are calulated per cm^-3 water
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

if(h2o.scale & ec.conc) {
  F_adsorp <- function (C1w, C1s, C2w, C2s, Mtot, k, moist, fc, depth) {
    mmod <- min(1, moist / fc) # for scaling M and Cs from 0-1 between 0 and fc
    C1 <- C1w / (depth * moist)
    C2 <- C2w / (depth * moist)
    M <- (Mtot - C1s - C2s) * mmod
    return( (C1 * M * k) * depth ) # this should be changed to reflect competetion effects
  }
  F_desorp <- function (Cs, k, moist, fc, depth) {
    mmod <- min(1, moist / fc) # for scaling M and Cs from 0-1 between 0 and fc
    Cs1 <- Cs / depth * mmod
    return( Cs1 * k)
  }
} else if(h2o.scale & !ec.conc) {
  F_adsorp <- function (C1w, C1s, C2w, C2s, Mtot, k, moist, fc, depth) {
    mmod <- min(1, moist / fc) # for scaling M and Cs from 0-1 between 0 and fc
    C1 <- C1w / depth
    C2 <- C2w / depth
    M <- (Mtot - C1s - C2s) * mmod
    return( (C1 * M * k) * depth ) # this should be changed to reflect competetion effects
  }
  F_desorp <- function (Cs, k, moist, fc, depth) {
    mmod <- min(1, moist / fc) # for scaling M and Cs from 0-1 between 0 and fc
    Cs1 <- Cs / depth * mmod
    return( Cs1 * k)
  }
} else if(!h2o.scale & ec.conc) {
  F_adsorp <- function (C1w, C1s, C2w, C2s, Mtot, k, moist, fc, depth) {
    C1 <- C1w / (depth * moist)
    C2 <- C2w / (depth * moist)
    M <- (Mtot - C1s - C2s)
    return( (C1 * M * k) * depth ) # this should be changed to reflect competetion effects
  }
  F_desorp <- function (Cs, k, moist, fc, depth) {
    Cs1 <- Cs / depth
    return( Cs1 * k)
  }
} else if(!h2o.scale & !ec.conc) {
  F_adsorp <- function (C1w, C1s, C2w, C2s, Mtot, k, moist, fc, depth) {
    mmod <- min(1, moist / fc) # for scaling M and Cs from 0-1 between 0 and fc
    C1 <- C1w / (depth)
    C2 <- C2w / (depth)
    M <- (Mtot - C1s - C2s)
    return( (C1 * M * k) * depth  ) # this should be changed to reflect competetion effects
  }
  F_desorp <- function (Cs, k, moist, fc, depth) {
    Cs1 <- Cs / depth
    return( Cs1 * k)
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


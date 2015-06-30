# temperature_functions.r
# After to Tang and Riley 2014 (supplementary information)

# Temperature response for equilibrium reactions (for K values)
Temp.Resp.Eq <- function(K, T, T0, E, R) {
  K * exp(-E/R * (1/T-1/T0))
}

# Temperature response for non-equilibrium reactions (for V values)
Temp.Resp.NonEq <- function(K, T, T0, E, R) {
  K * T/T0 * exp(-E/R * (1/T-1/T0))
}

# plot(function(x){exp(-15000/8.31 * (1/x-1/290))}, 273,290)

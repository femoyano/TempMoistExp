# temperature_functions.r
# After to Tang and Riley 2014 (supplementary information)

# For equilibrium reactions
Temp.Resp.Eq <- function(K, T, T0, G, R) {
  K * exp(-G/R * (1/T-1/T0))
}

# For non-equilibrium reactions
Temp.Resp.NonEq <- function(K, T, T0, G, R) {
  K * T/T0 * exp(-G/R * (1/T-1/T0))
}

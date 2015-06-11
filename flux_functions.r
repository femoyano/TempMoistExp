# flux_functions.r 

# Functions calculating the change in each state variable are defined here.

FluxLC <- function(litter_m) {
  F_ml.lc <- litter_m
  F_ec.lc <- ECw * Em
  
}
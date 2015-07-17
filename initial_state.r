# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 37.8     , # [gC] labile carbon (array: point x layer)
  SC  = 0.026  , # [gC] soluble carbon (array: point x layer)
  EC  = 0.0014  , # [mgC] enzymes (array: point x layer)
  MC  = 0.25   , # [mgC] microbial carbon (array: point x layer)
  CO2 = 0 
)

# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 0 , # [gC] labile carbon (array: point x layer)
  SC  = 0 , # [gC] soluble carbon (array: point x layer)
  EC  = 0.001 , # [mgC] enzymes (array: point x layer)
  MC  = 0.01 , # [mgC] microbial carbon (array: point x layer)
  CO2 = 0 
)

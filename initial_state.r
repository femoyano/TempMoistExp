# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 37.8     , # [gC] labile carbon (array: point x layer)
  SCb  = 0.026   , # [gC] soluble carbon in bulk (array: point x layer)
  SCm  = 0.0     , # [gC] soluble carbon at microbe (array: point x layer)
  ECb  = 0.0014  , # [mgC] enzymes in bulk (array: point x layer)
  ECm  = 0.00    , # [mgC] enzymes at microbe (array: point x layer)
  MC  = 0.25     , # [mgC] microbial carbon (array: point x layer)
  CO2 = 0 
)

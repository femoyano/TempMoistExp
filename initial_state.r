# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 15000   , # [gC cm-3] labile carbon (array: point x layer)
  SCb = 200    , # [gC cm-3] soluble carbon in bulk (array: point x layer)
  SCm = 10   , # [gC cm-3] soluble carbon at microbe (array: point x layer)
  ECb = 0.8   , # [gC cm-3] enzymes in bulk (array: point x layer)
  ECm = 12     , # [gC cm-3] enzymes at microbe (array: point x layer)
  MC  = 150    , # [gC cm-3] microbial carbon (array: point x layer)
  CO2 = 0          # [gC] microbial carbon (array: point x layer)
)

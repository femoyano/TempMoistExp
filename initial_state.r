# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 5000  , # [gC m-3] labile carbon 
  SCb = 137   , # [gC m-3] soluble carbon in bulk 
  SCm = 14    , # [gC m-3] soluble carbon at microbe 
  SCs = 481   , # [gC m-3] sorbed SC
  ECb = 0.57  , # [gC m-3] enzymes in bulk 
  ECm = 8     , # [gC m-3] enzymes at microbe 
  ECs = 2     , # [gC m-3]sorbed EC
  MC  = 102   , # [gC m-3] microbial carbon 
  CO2 = 0       # [gC] microbial carbon 
)

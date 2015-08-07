# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 11500  , # [gC m-3] labile carbon 
  SCw = 300   , # [gC m-3] soluble carbon in bulk 
  SCs = 500   , # [gC m-3] sorbed SC
  ECb = 0.7 , # [gC m-3] enzymes in bulk 
  ECm = 8     , # [gC m-3] enzymes at microbe 
  ECs = 1.1     , # [gC m-3]sorbed EC
  CO2 = 0       # [gC] microbial carbon 
)

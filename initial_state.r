# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  PC  = 5000   , # [gC cm-3] labile carbon 
  SCb = 200    , # [gC cm-3] soluble carbon in bulk 
  SCm = 10   , # [gC cm-3] soluble carbon at microbe 
  SCs = 0     , # [gC cm-3] sorbed SC
  ECb = 0.8   , # [gC cm-3] enzymes in bulk 
  ECm = 12     , # [gC cm-3] enzymes at microbe 
  ECs = 0      , # [gC cm-3]sorbed EC
  MC  = 150    , # [gC cm-3] microbial carbon 
  CO2 = 0          # [gC] microbial carbon 
)

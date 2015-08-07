# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

# initial_state <- c(
#   PC  = 1  , # [gC m-3] labile carbon 
#   SCw = 280    , # [gC m-3] soluble carbon in bulk 
#   SCs = 507    , # [gC m-3] sorbed SC
#   ECb = 0.6    , # [gC m-3] enzymes in bulk 
#   ECm = 8.4    , # [gC m-3] enzymes at microbe 
#   ECs = 1.08   , # [gC m-3]sorbed EC
#   CO2 = 0        # [gC] microbial carbon 
# )

# At equilibrium...
initial_state <- c(
  PC  = 11231  , # [gC m-3] labile carbon 
  SCw = 280    , # [gC m-3] soluble carbon in bulk 
  SCs = 507    , # [gC m-3] sorbed SC
  ECb = 0.6    , # [gC m-3] enzymes in bulk 
  ECm = 8.4    , # [gC m-3] enzymes at microbe 
  ECs = 1.08   , # [gC m-3]sorbed EC
  CO2 = 0        # [gC] microbial carbon 
)

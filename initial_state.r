# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode
if(spinup) {
initial_state <- c(
  PC  = 10  , # [gC m-3] labile carbon 
  SCw = 10  , # [gC m-3] soluble carbon in bulk 
  SCs = 10  , # [gC m-3] sorbed SC
  ECb = 1   , # [gC m-3] enzymes in bulk 
  ECm = 1   , # [gC m-3] enzymes at microbe 
  ECs = 1   , # [gC m-3]sorbed EC
  CO2 = 0     # [gC] microbial carbon 
)
} else {
  initial_state <- c(
    PC  = 7000  , # [gC m-3] labile carbon 
    SCw = 137   , # [gC m-3] soluble carbon in bulk 
    SCs = 481   , # [gC m-3] sorbed SC
    ECb = 0.57  , # [gC m-3] enzymes in bulk 
    ECm = 8     , # [gC m-3] enzymes at microbe 
    ECs = 2     , # [gC m-3]sorbed EC
    CO2 = 0       # [gC] microbial carbon 
  )
}

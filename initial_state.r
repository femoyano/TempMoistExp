# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode
if(spinup) {
initial_state <- c(
  PC  = 1   , # [gC m-3] labile carbon 
  SCw = 1   , # [gC m-3] soluble carbon in bulk 
  SCs = 1   , # [gC m-3] sorbed SC
  ECw = 1   , # [gC m-3] enzymes in bulk 
  ECs = 1   , # [gC m-3]sorbed EC
  MC  = 1   , # [gC m-3] microbial C
  CO2 = 0     # [gC] microbial carbon 
)
} else {
  initial_state <- c(
    PC  = 7000  , # [gC m-3] labile carbon 
    SCw = 137   , # [gC m-3] soluble carbon in bulk 
    SCs = 481   , # [gC m-3] sorbed SC
    ECw = 0.57  , # [gC m-3] enzymes in bulk 
    ECs = 2     , # [gC m-3] sorbed EC
    MC  = 1     , # [gC m-3] microbial C
    CO2 = 0       # [gC] microbial carbon 
  )
}

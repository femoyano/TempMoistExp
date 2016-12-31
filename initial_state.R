#### initial_state.r

#### Documentation ============================================================
# Sets the initial values for the state variables
# Needs to be a named vector for using ode
#### ==========================================================================

if(spinup) {
  initial_state <- c(
    C_P = 1   , # [gC m-3] particulate carbon 
    C_D = 1   , # [gC m-3] soluble carbon 
    C_E = 1   , # [gC m-3] enzyme carbon
    C_M = 1   , # [gC m-3] microbial carbon
    C_R = 0     # [gC] respired carbon
  )
} else {
  initial_state <- c(
    C_P = 7000  , # [gC m-3] particulate carbon 
    C_D = 137   , # [gC m-3] soluble carbon 
    C_E = 0.57  , # [gC m-3] enzymes carbon
    C_M = 1     , # [gC m-3] microbial carbon
    C_R = 0       # [gC] respired carbon 
  )
}

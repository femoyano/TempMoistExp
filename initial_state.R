#### initial_state.r

#### Documentation ============================================================
# Sets the initial values for the state variables
# Needs to be a named vector for using ode
#### ==========================================================================

if(spinup) {
  initial_state <- c(
    C_P  = 100   , # particulate carbon 
    C_D  = 0.01  , # soluble carbon 
    C_E  = 0.01  , # enzyme carbon
    C_M  = 1     , # microbial carbon
    C_Rg  = 0    , # growth respiration
    C_Rm  = 0      # maintenance respiration
  )
} else {
  initial_state <- c(
    C_P  = 7000  , # particulate carbon 
    C_D  = 1     , # soluble carbon 
    C_E  = 1     , # enzymes carbon
    C_M  = 100   , # microbial carbon
    C_Rg  = 0    , # growth respiration
    C_Rm  = 0      # maintenance respiration
  )
}

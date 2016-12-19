#### initial_state.r

#### Documentation ============================================================
# Sets the initial values for the state variables
# Needs to be a named vector for using ode
#### ==========================================================================

# Units in kgC m-3 (Dec. 2016)

if(spinup) {
  initial_state <- c(
    C_P  = 100   , # particulate carbon 
    C_D  = 1     , # soluble carbon 
    C_E  = 0.01  , # enzyme carbon
    C_Em = 0.01  , # enzyme carbon at microbes
    C_M  = 1     , # microbial carbon
    C_Rg  = 0    , # growth respiration
    C_Rm  = 0      # maintenance respiration
  )
} else {
  initial_state <- c(
    C_P  = 7000  , # particulate carbon 
    C_D  = 137   , # soluble carbon 
    C_E  = 1     , # enzymes carbon
    C_Em = 1     , # enzyme carbon at microbes
    C_M  = 100   , # microbial carbon
    C_Rg  = 0    , # growth respiration
    C_Rm  = 0      # maintenance respiration
  )
}

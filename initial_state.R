#### initial_state.r

#### Documentation ============================================================
# Sets the initial values for the state variables
# Needs to be a named vector for using ode
#### ==========================================================================

if(spinup) {
  initial_state <- c(
    C_P  = 1   , # [gC m-3] labile carbon 
    C_D = 1   , # [gC m-3] soluble carbon in bulk 
    C_A = 1   , # [gC m-3] sorbed C_D
    C_Ew = 1   , # [gC m-3] enzymes in bulk
    C_Em = 1   , # ...
    C_M  = 1   , # [gC m-3] microbial C
    C_R = 0     # [gC] microbial carbon 
  )
} else {
  initial_state <- c(
    C_P  = 7000  , # [gC m-3] labile carbon 
    C_D = 137   , # [gC m-3] soluble carbon in bulk 
    C_A = 481   , # [gC m-3] sorbed C_D
    C_Ew = 0.57  , # [gC m-3] enzymes in bulk 
    C_Em = 1   , # ...
    C_M  = 1     , # [gC m-3] microbial C
    C_R = 0       # [gC] microbial carbon 
  )
}

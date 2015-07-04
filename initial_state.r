# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  LC  = 1000 , # [gC] labile carbon (array: point x layer)
  RC  = 1000 , # [gC] recalcitrant carbon (array: point x layer)
  SCw = 0 , # [gC] soluble carbon in bulk water (array: point x layer)
  SCs = 0 , # [gC] soluble carbon sorbed to minerals (array: point x layer)
  SCi = 0 , # [gC] soluble immobile carbon (in dry zones) (array: point x layer)
  SCm = 0 , # [gC] soluble carbon local to microbes (array: point x layer)
  ECw = 0 , # [gC] enzymes in bulk water (array: point x layer)
  ECs = 0 , # [gC] enzymes sorbed to minerals (array: point x layer)
  ECm = 0 , # [gC] enzymes local to microbes (array: point x layer)
  MC  = 1 , # [gC] microbial carbon (array: point x layer)
  CO2 = 0 
)

# initial_state.r

# Documentation ====
# Sets the initial values for the state variables
# Needs to be a named vector for using ode

initial_state <- c(
  LC  = 0 , # [g] labile carbon (array: point x layer)
  RC  = 0 , #  # [g] recalcitrant carbon (array: point x layer)
  SCw = 0 , # [g] soluble carbon in bulk water (array: point x layer)
  SCs = 0 , # [g] soluble carbon sorbed to minerals (array: point x layer)
  SCi = 0 , # [g] soluble immobile carbon (in dry zones) (array: point x layer)
  SCm = 0 , # [g] soluble carbon local to microbes (array: point x layer)
  ECw = 0 , # [g] enzymes in bulk water (array: point x layer)
  ECs = 0 , # [g] enzymes sorbed to minerals (array: point x layer)
  ECm = 0 , # [g] enzymes local to microbes (array: point x layer)
  MC  = 0 , # [g] microbial carbon (array: point x layer)
  CO2 = 0 
)

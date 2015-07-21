# inputs
### Climate forcing and litter input ===========================================

### Documentation ==============================================================
# Forcing and litter data time should be in daily units
# Forcing data will be interpolated to model time step
# Soil T must be in kelvin and soil moisture in volumetric content
# Litter input must be in gC m-2 d-1
### ============================================================================

# forcing.data   <- read.csv("input_forcing.csv") # forcing data file
# # convert time units
# forcing.data$day <- forcing.data$day * (day / tstep)
# names(forcing.data)[1] <- t_step

forcing.data <- data.frame(hour=1, temp = 283.15)

# litter.data    <- read.csv("input_litter.csv") # litter input rates file
# # convert time units 
# litter.data$day <- litter.data$day * (day / tstep)
# names(litter.data)[1] <- t_unit
# # convert litter input rates to the model time step rate
# litter.data[,-1] <- litter.data[,-1] / day * tstep

litter.data <- data.frame(hour=1, litter_str = 0.00015, litter_met = 0.00001)

# ### Spatial Variables ==========================================================
# clay   <- 0.51  # [g g^-1] clay fraction values 
# sand   <- 0.03  # [g g^-1] sand fraction values 
# silt   <- 0.46  # [g g^-1] silt fraction values 
# phi    <- 0.5   # [m^3 m^-3] soil pore space
# depth  <- 0.30  # [m] soil depth

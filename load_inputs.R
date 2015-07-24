# inputs
### Climate forcing and litter input ===========================================

### Documentation ==============================================================
# Forcing and litter data time should be in hourly units
# Forcing data will be interpolated to model time step
# Soil T must be in kelvin and soil moisture in volumetric content
# Litter input must be in gC m-2 d-1
### ============================================================================

### Spatial Variables ==========================================================
sand   <- 0.30  # [g g^-1] clay fraction values 
clay   <- 0.30  # [g g^-1] sand fraction values 
silt   <- 0.10  # [g g^-1] silt fraction values 
phi    <- 0.5   # [m^3 m^-3] soil pore space
depth  <- 0.30  # [m] soil depth

### Temporal Variables
data.t_step <- hour

# Field capacity calculation to use as input
psi_fc  <- 33
b       <- 2.91 + 15.9 * clay                 # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000       # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
fc      <- phi * (psi_sat / psi_fc)^(1 / b)   # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.

# forcing.data   <- read.csv("input_forcing.csv") # forcing data file
forcing.data <- data.frame(hour=c(1,2), temp = c(293.15, 293.15), moist=c(fc, fc))
forcing.data[, 1] <- forcing.data[, 1] * (data.t_step / tstep) # convert time units
names(forcing.data)[1] <- t_step

# litter.data    <- read.csv("input_litter.csv") # litter input rates file
litter.data <- data.frame(hour=c(1,2), litter_str = c(0.00015, 0.00015), litter_met = c(0.00001, 0.00001))
litter.data[, 1] <- litter.data[, 1] * (data.t_step / tstep) # convert time units 
names(litter.data)[1] <- t_step
litter.data[,-1] <- litter.data[,-1] / data.t_step * tstep # convert litter input rates to the model time step rate


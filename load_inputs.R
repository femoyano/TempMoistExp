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
ps     <- 0.5   # [m^3 m^-3] soil pore space
pd     <- 2.7   # [g cm-3] soil particule density
depth  <- 0.30  # [m] soil depth

### Temporal Variables =========================================================
data.t_step <- hour

### Field capacity calculation to use as input =================================
psi_fc  <- 33
b       <- 2.91 + 15.9 * clay                # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000      # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
fc      <- ps * (psi_sat / psi_fc)^(1 / b)   # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.

### Forcing Data ===============================================================

# forcing.data   <- read.csv("input_forcing.csv") # forcing data file
forcing.data <- data.frame(hour=c(1,2), temp = c(293.15, 293.15), moist=c(fc, fc))
forcing.data[, 1] <- forcing.data[, 1] * (data.t_step / tstep) # convert time units
names(forcing.data)[1] <- t_step

### Litter Input Data ==========================================================

## Option 1: use literature data and scale up to soil layer
litt_met <- 0.00001 * 1000000 * pd * (1 - ps) / 1000 * depth # [gC m-2] mgC gSoil-1 (from Li et al.) to gC m-2
litt_str <- 0.00015 * 1000000 * pd * (1 - ps) / 1000 * depth # [gC m-2] mgC gSoil-1 (from Li et al.) to gC m-2
litter.data <- data.frame(hour=seq(1,2), litter_str = rep(litt_str, 2), litter_met = rep(litt_met, 2))

## Option 2: read from file (e.g. field litter data)
# litter.data    <- read.csv("input_litter.csv") # litter input rates file
# litter.data[, 1] <- litter.data[, 1] * (data.t_step / tstep) # convert time units 
# names(litter.data)[1] <- t_step
# litter.data[,-1] <- litter.data[,-1] / data.t_step * tstep # convert litter input rates to the model time step rate


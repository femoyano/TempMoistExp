### Climate forcing and litter input ===========================================

### Documentation ==============================================================
# Forcing and litter data time should be in hourly units
# Forcing data will be interpolated to model time step
# Soil T must be in kelvin and soil moisture in volumetric content
# Litter input must be in gC m-2 h-1

### Option 1: input data from file  ============================================

# Spatial soil data
soil.data  <- read.csv(soil.file)

# Forcing and input data
input.data <- read.csv(input.file) # input data file

### Option 2: manually enter input data ======================================== ####

# Field capacity calculation to use as input

# sand   <- 0.70  # [g g^-1] clay fraction values 
# clay   <- 0.10  # [g g^-1] sand fraction values 
# silt   <- 0.20  # [g g^-1] silt fraction values 
# ps     <- 0.5   # [m^3 m^-3] soil pore space
# depth  <- 0.30  # [m] soil depth

# Calculate fc for use as input
# psi_fc  <- 33
# b       <- 2.91 + 15.9 * clay                # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
# psi_sat <- exp(6.5 - 1.3 * sand) / 1000      # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
# fc      <- ps * (psi_sat / psi_fc)^(1 / b)   # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.

#   litt_met   <- 0.00001 * 1000000 * 2.7 * (1 - ps) / 1000 * depth # [gC m-2 h-1] mgC gSoil-1 (from Li et al.) to gC m-2
#   litt_str   <- 0.00015 * 1000000 * 2.7 * (1 - ps) / 1000 * depth # [gC m-2 h-1] mgC gSoil-1 (from Li et al.) to gC m-2
#   input.data <- data.frame(hour=seq(1,2), temp = c(293.15, 293.15), moist=c(fc, fc), litter_str = rep(litt_str, 2), litter_met = rep(litt_met, 2))

### Extract variables ==========================================================

temp        <- input.data$temp       # [K] soil temperature
moist       <- input.data$moist      # [m3 m-3] specific soil volumetric moisture
litter_sc   <- input.data$litter_met # [mgC m^2] metabolic litter going to sc
litter_pc   <- input.data$litter_str # [mgC m^2] structural litter going to pc
times_input <- input.data[,1]        # time vector of input data

litter_sc   <- litter_sc / hour * tstep # convert litter input rates to the model time step rate
litter_pc   <- litter_pc / hour * tstep # convert litter input rates to the model time step rate

# convert times to model times
input.tstep <- get(names(input.data)[1])
times_input <- times_input * input.tstep / tstep

sand   <- soil.data$sand  # [g g^-1] clay fraction values 
clay   <- soil.data$clay  # [g g^-1] sand fraction values 
silt   <- soil.data$silt  # [g g^-1] silt fraction values 
ps     <- soil.data$ps    # [m^3 m^-3] soil pore space
depth  <- soil.data$depth # [m] soil depth

rm(input.data, soil.data)

### Obtain data times: start and end ===========================================

start <- times_input[1]
end   <- tail(times_input, 1)



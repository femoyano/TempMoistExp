### Climate forcing and litter input ===========================================

### Documentation ==============================================================
# Forcing data will be interpolated to model time step
# Soil T must be in kelvin and soil moisture in volumetric content
# Litter input must be in gC m-2 h-1
# Requires: tunit

### Option 1: input data from file  ============================================

# Spatial soil data
site.data  <- read.csv(site.file)

# Forcing and input data
input.data <- read.csv(input.file) # input data file

### Option 2: manually enter input data ========================================

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


### Adjust time units and extract data ========================================
times.input <- input.data[,1]        # time vector of input data
input.tstep <- get(names(input.data)[1])
times.input <- times.input * input.tstep / tunit # convert input data to model step unit

times_input <- input.data[,1]        # time of input data
temp        <- input.data$temp       # [K] soil temperature
moist       <- input.data$moist      # [m3 m-3] specific soil volumetric moisture
litter_met  <- input.data$litter_met / hour * tunit # [mgC m^-2 tunit^-1] convert litter input rates to the model rate
litter_str  <- input.data$litter_str / hour * tunit # [mgC m^-2 tunit^-1] convert litter input rates to the model rate

sand   <- site.data$sand  # [g g^-1] clay fraction values 
clay   <- site.data$clay  # [g g^-1] sand fraction values 
silt   <- site.data$silt  # [g g^-1] silt fraction values 
ps     <- site.data$ps    # [m^3 m^-3] soil pore space
depth  <- site.data$depth # [m] soil depth

rm(input.data, site.data, times.input, input.tstep)

### Obtain data times: start and end ===========================================

start <- times_input[1]
end   <- tail(times_input, 1)



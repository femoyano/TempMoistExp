### Climate forcing and litter input =========================================

### Documentation ============================================================
# Forcing data will be interpolated to model time step
# Soil T must be in kelvin and soil moisture in volumetric content
# Litter input must be in gC m-2 h-1
# Requires: tstep

### Spatial soil data =========================================================

site.data  <- read.csv(site.file)

sand   <- site.data$sand  # [g g^-1] clay fraction values 
clay   <- site.data$clay  # [g g^-1] sand fraction values 
silt   <- site.data$silt  # [g g^-1] silt fraction values 
ps     <- site.data$ps    # [m^3 m^-3] soil pore space
depth  <- site.data$depth # [m] soil depth

### Climate and litter data ===================================================

input.data <- read.csv(input.file) # input data file

# Adjust time units and extract data
times.input <- input.data[,1]        # time vector of input data
input.tstep <- get(names(input.data)[1])
times.input <- times.input * input.tstep / tstep # convert input data to model step unit

times_input <- input.data[,1]        # time of input data
temp        <- input.data$temp       # [K] soil temperature
moist       <- input.data$moist      # [m3 m-3] specific soil volumetric moisture
litter_met  <- input.data$litter_met / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate
litter_str  <- input.data$litter_str / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate

rm(input.data, site.data, times.input, input.tstep)

# Obtain data times: start and end

start <- times_input[1]
end   <- tail(times_input, 1)

# Prepare input data

litter_str <- approx(times_input, litter_str, xout=seq(start, end), rule=2)$y
litter_met <- approx(times_input, litter_met, xout=seq(start, end), rule=2)$y
temp       <- approx(times_input, temp      , xout=seq(start, end), rule=2)$y
moist      <- approx(times_input, moist     , xout=seq(start, end), rule=2)$y

if(spinup) {
  if(flag.cmi) { # if a constant mean values should be used
    
    litter_str  <- rep(mean(litter_str, na.rm=TRUE), length.out = 2)
    litter_met  <- rep(mean(litter_met, na.rm=TRUE), length.out = 2)
    temp        <- rep(mean(temp      , na.rm=TRUE), length.out = 2)
    moist       <- rep(mean(moist     , na.rm=TRUE), length.out = 2)
    
    times_input <- c(1,2)
    
  } else {       # else
    
    temp       <- rep(temp      , length.out = spin.time)
    moist      <- rep(moist     , length.out = spin.time)
    litter_str <- rep(litter_str, length.out = spin.time)
    litter_met <- rep(litter_met, length.out = spin.time)
    
    times_input <- seq(1, spin.time)
    
  } # end of if else (flag.cmi)
} # end of if(spinup)

if(flag.des) { # if diff. eq. solver is used define input interpolation functions
  Approx_litter_str <- approxfun(times_input, litter_str, method = "linear", rule = 2)
  Approx_litter_met <- approxfun(times_input, litter_met, method = "linear", rule = 2)
  Approx_temp       <- approxfun(times_input, temp      , method = "linear", rule = 2)
  Approx_moist      <- approxfun(times_input, moist     , method = "linear", rule = 2)
}

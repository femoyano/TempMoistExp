#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SoilBGC.

### Libraries ==================================================================
require(deSolve)

### Setup variables if run script is not used ==================================
if(!exists("runscript")) {
  # flags
  adsorption  <- 0  # should adsorption desortion rates be simulated
  microbes    <- 1  # should microbes be explicitly represented?
  h2o.scale    <- 1  # should available pc scale with moisture (with max at fc)?
  pc.conc     <- 1  # should available pc concentration change with moisture?
  ec.conc     <- 1  # should SC concentration change with moisture?
  #setup
  input.file   <- "input.csv"
  site.file    <- "site.csv"
  spinup       <- TRUE    # If TRUE then spinup run and data will be recylced.
  eq.stop      <- FALSE   # Stop at equilibrium?
  eq.md        <- 1       # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.
  spin.years   <- 5000    # years for spinup runs
  t.unit       <- "hour"  # time unit for all rates values
  t.save.spin  <- "year"  # interval at which to save output during spinup runs (text).
  t.save.trans <- "day"   # interval at which to save output during transient runs (text).
  source("initial_state.r")
}

### Define time quantities
year  <- 31104000 # seconds in a year
month <- 2592000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
sec   <- 1        # seconds in a second!

tunit <- get(t.unit)

## Sourced required files
source("parameters.r")
source("flux_functions.r")
source("Model.R")

## Load input data
source("load_inputs.R")

# Define vector with times for model output
spin.time <- spin.years * year / tunit
t.save.s <- get(t.save.spin) / tunit
t.save.t <- get(t.save.trans) / tunit
if(spinup) times <- seq(0, spin.time, t.save.s) else times <- seq(start, end, t.save.t)

# If spinup, use average of input data
if(spinup) {
  litter_str  <- rep(mean(litter_str, na.rm=TRUE), length.out = 2)
  litter_met  <- rep(mean(litter_met, na.rm=TRUE), length.out = 2)
  temp        <- rep(mean(temp      , na.rm=TRUE), length.out = 2)
  moist       <- rep(mean(moist     , na.rm=TRUE), length.out = 2)
  times_input <- c(1,2)
}

# Define input variables interpolation functions
Approx_litter_str <- approxfun(times_input, litter_str, method = "linear", rule = 2)
Approx_litter_met <- approxfun(times_input, litter_met, method = "linear", rule = 2)
Approx_temp       <- approxfun(times_input, temp      , method = "linear", rule = 2)
Approx_moist      <- approxfun(times_input, moist     , method = "linear", rule = 2)

# Calculate spatially changing variables and add to parameter list
b       <- 2.91 + 15.9 * clay                     # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000           # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
Rth     <- pars[["ps"]] * (psi_sat / pars[["psi_Rth"]])^(1 / b) # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
fc      <- ps * (psi_sat / pars[["psi_fc"]])^(1 / b)        # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
M       <- 200 * (100 * clay)^0.6 * pars[["pd"]] * (1 - ps) # [g m-3] Total C-equivalent mineral surface for sorption (Mayes et al. 2012)

pars <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, b = b, psi_sat = psi_sat, Rth = Rth, fc = fc, M = M) # add all new parameters

# Run the differential equation solver
out <- ode(initial_state, times, Model, pars)

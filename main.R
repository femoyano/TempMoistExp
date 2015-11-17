#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SoilBGC.

### Libraries ==================================================================
require(deSolve)

### Setup variables if run script is not used ==================================
if(!exists("runscript")) {
  input.file   <- "input.csv"
  site.file    <- "site.csv"
  spinup       <- TRUE    # If TRUE then spinup run and data will be recylced.
  eq.stop      <- FALSE   # Stop at equilibrium?
  eq.md        <- 1       # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.
  t.max.spin   <- 100000  # maximum run time for spinup runs (in t_step units)
  t.save.spin  <- "year"  # interval at which to save output during spinup runs (text).
  t.save.trans <- "day"   # interval at which to save output during transient runs (text).
  source("initial_state.r")
}

### Define time quantities ==========================================================
year  <- 31104000 # seconds in a year
month <- 2592000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
sec   <- 1        # seconds in a second!

# Sourced files
source("parameters.r")
source("flux_functions.r")
source("Model.R")

# Load input data
source("load_inputs.R")

# Define vector with times for model output
t.save.s <- get(t.save.spin)
t.save.t <- get(t.save.trans)
ifelse(spinup, times <- seq(0, t.max.spin, 8640), times <- seq(start, end))

# Interpolate input variables
litter_str <- approxfun(times_input, litter_str, method = "linear", rule = 2)
litter_met <- approxfun(times_input, litter_met, method = "linear", rule = 2)
temp       <- approxfun(times_input, temp      , method = "linear", rule = 2)
moist      <- approxfun(times_input, moist     , method = "linear", rule = 2)

# If spinup, repeat input data
if(spinup) {
  litter_str <- rep(litter_str, length.out = t.max.spin)
  litter_met <- rep(litter_met, length.out = t.max.spin)
  temp       <- rep(temp      , length.out = t.max.spin)
  moist      <- rep(moist     , length.out = t.max.spin)
}

# Calculate spatially changing variables and add to parameter list
pars <- c(
  parameters,
  b       = 2.91 + 15.9 * clay,                     # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
  psi_sat = exp(6.5 - 1.3 * sand) / 1000,           # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
  Rth     = ps * (psi_sat / psi_Rth)^(1 / b),       # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
  fc      = ps * (psi_sat / psi_fc)^(1 / b),        # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
  M       = 200 * (100 * clay)^0.6 * pd * (1 - ps) # [g m-3] Total C-equivalent mineral surface for sorption (Mayes et al. 2012)
)

out <- Model(initial_state, times, Model, pars)

#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SoilBGC

### Libraries ==================================================================
require(deSolve)

### Setup variables if run script is not used ==================================
if(!exists("runscript")) {
  # Flags
  flag.ads  <- 0  # model adsorption desorption rates?
  flag.mic  <- 0  # model microbial pool explicitly?
  flag.fcs  <- 1  # scale PC, SCs, M with moisture (with max at fc)?
  flag.sew  <- 1  # calculate EC and SC concentration in water?
  flag.des  <- 0  # run using differential equation solver?
  flag.cmi  <- 0  # use a constant mean input for spinup?
  
  # Setup
  input.file   <- "input.csv"
  site.file    <- "site.csv"
  spinup       <- FALSE   # If TRUE then spinup run and data will be recylced.
  eq.stop      <- FALSE   # Stop at equilibrium?
  eq.md        <- 1       # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.
  spin.years   <- 5000    # years for spinup runs
  t_step       <- "hour"  # time unit for all rates values
  t_save       <- "month"  # interval at which to save output during spinup runs (text).
  source("initial_state.R")
}

### Define time units ==========================================================
year     <- 31104000 # seconds in a year
month    <- 2592000  # seconds in a month
day      <- 86400    # seconds in a day
hour     <- 3600     # seconds in an hour
halfhour <- 1800     # seconds in half an hour
tenmin   <- 600      # seconds in 10 minutes
sec      <- 1        # seconds in a second!

tstep <- get(t_step)
tsave <- get(t_save)

## Sourced required files
source("parameters.R")
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")

## Load and prepare input data
source("load_inputs.R")

### Prepare time vector used during simulation
spin.time <- spin.years * year / tstep
if(flag.des) { # If using deSolve, create vector of save times only
  t.save.s <- get(t.save.spin) / tstep
  t.save.t <- get(t.save.trans) / tstep
  if(spinup) times <- seq(0, spin.time, t.save.s) else times <- seq(start, end, t.save.t)
} else { # if doing fixed step, create vector of every time step
  if(spinup) times <- seq(1, spin.time) else times <- seq(start, end)
}

## Calculate spatially changing variables and add to parameter list
b       <- 2.91 + 15.9 * clay                         # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000               # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
Rth     <- ps * (psi_sat / pars[["psi_Rth"]])^(1 / b) # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
fc      <- ps * (psi_sat / pars[["psi_fc"]])^(1 / b)  # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
Md       <- 200 * (100 * clay)^0.6 * pars[["pd"]] * (1 - ps) # [g m-3] Mineral surface adsorption density in C-equivalent (Mayes et al. 2012)

pars <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, b = b, psi_sat = psi_sat, Rth = Rth, fc = fc, Md = Md) # add all new parameters

ptm <- proc.time() # save current time to later check run time
if(flag.des) { # if true, run the differential equation solver
  out <- ode(initial_state, times, Model_desolve, pars, method = ode.method)
} else { # else run the stepwise simulation
  out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, pars, temp, moist, litter_str, litter_met)
}
print(proc.time()-ptm) # check run time



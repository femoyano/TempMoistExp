#### optim_run_script.R

#### Documentations ===========================================================
# Script used to prepare settings and run parameter optimization by 
# calling main_optim.R
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

rm(list=ls()) # clear the work space

###############################################################################
### User Settings =============================================================
###############################################################################

### Required settings (will affect output) ====================================

# Model flag options ----------------------------------------------------------
flag.ads  <- 0  # simulate adsorption desorption rates
flag.mic  <- 0  # simulate microbial pool explicitly
flag.fcs  <- 1  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
flag.sew  <- 1  # calculate C_E and C_D concentration in water
flag.des  <- 1  # run using differential equation solver? If TRUE then t_step has no effect.

# Input Setup -----------------------------------------------------------------
site.name       <- "Wetzstein"
input.data      <- "Wetzstein2007SM16"
t_step          <- "hour"        # Model time step (as string). Important when using stepwise run.
t_save          <- "month"
spin.years      <- 5         # maximum years for spinup run
flag.cmi        <- 1         # use a constant mean input for spinup
ode.method      <- "lsoda"       # see ode function
# eq.stop <- 0  # should a spinup run stop when soil C is close enough to equilibrium?
# eq.md   <- 10 # equilibrium maximum difference allowed for C_P (in gC m-3 y-1)

### Input-output file and path names ==========================================
# input
times_data  <- 0000 #what here?
input.path  <- file.path("..", "Input")
input.file  <- file.path(input.path, paste("input_" , input.data, ".csv", sep=""))
site.file   <- file.path(input.path, paste("site_"  , site.name  , ".csv", sep=""))

###############################################################################
### Non User Settings =========================================================
###############################################################################
### Libraries =================================================================
require(deSolve)

### Setup variables if run script is not used =================================
tstep <- get(t_step)
tsave <- get(t_save)

### Define time units =========================================================
year     <- 31104000 # seconds in a year
month    <- 2592000  # seconds in a month
day      <- 86400    # seconds in a day
hour     <- 3600     # seconds in an hour
halfhour <- 1800     # seconds in half an hour
tenmin   <- 600      # seconds in 10 minutes
sec      <- 1        # seconds in a second!

### Sourced required files ----------------------------------------------------
source("GetInitial.R")
source("parameters.R")
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")
source("optim_Costfun.R")
source("optim_Pricefit.R")

### Load and prepare input data -----------------------------------------------
source("load_inputs.R")

### Prepare input for spinups -------------------------------------------------

if(!flag.cmi) s.times_input <- times_input - times_input[1] + 1 # For no cmi spinups, make sure time starts at 1 (simplifies data recylcing).
s.start <- s.times_input[1]
s.end   <- tail(s.times_input, 1)

# If a constant mean values should be used:
if(spinup & flag.cmi) {
  s.I_sl  <- rep(mean(I_sl , na.rm=TRUE), length.out = 2)
  s.I_ml  <- rep(mean(I_ml , na.rm=TRUE), length.out = 2)
  s.temp_data   <- rep(mean(temp_data  , na.rm=TRUE), length.out = 2)
  s.moist_data  <- rep(mean(moist_data , na.rm=TRUE), length.out = 2)
  s.times_input  <- c(1,2)
}

# Define input interpolation functions for spinup
s.Approx_I_sl <- approxfun(s.times_input, s.I_sl , method = "linear", rule = 2)
s.Approx_I_ml <- approxfun(s.times_input, s.I_ml , method = "linear", rule = 2)
s.Approx_temp       <- approxfun(s.times_input, s.temp_data  , method = "linear", rule = 2)
s.Approx_moist      <- approxfun(s.times_input, s.moist_data , method = "linear", rule = 2)

# Prepare time vector used during simulation
spin.time <- spin.years * year / tstep
if(flag.des) { # If using deSolve, only save times are required
  t.save <- get(t_save) / tstep
  s.times <- seq(0, spin.time, t.save)
} else { # if running fixed steps, all time step are required
  s.times <- seq(1, spin.time)
}

### Prepare input for transient -------------------------------------------------

# Define input interpolation functions
t.Approx_I_sl <- approxfun(times_input, I_sl , method = "linear", rule = 2)
t.Approx_I_ml <- approxfun(times_input, I_ml , method = "linear", rule = 2)
t.Approx_temp       <- approxfun(times_input, temp_data  , method = "linear", rule = 2)
t.Approx_moist      <- approxfun(times_input, moist_data , method = "linear", rule = 2)

t.times <- times_input

## Calculate spatially changing variables and add to parameter list
b       <- 2.91 + 15.9 * clay                         # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000               # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
Rth     <- ps * (psi_sat / pars[["psi_Rth"]])^(1 / b) # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
fc      <- ps * (psi_sat / pars[["psi_fc"]])^(1 / b)  # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
Md       <- 200 * (100 * clay)^0.6 * pars[["pd"]] * (1 - ps) # [gC m-3] Mineral surface adsorption capacity in gC-equivalent (Mayes et al. 2012)

pars <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, b = b, psi_sat = psi_sat, Rth = Rth, fc = fc, Md = Md, end = end, spinup = spinup) # add all new parameters

## Call cost function -----------------------------------------------------------------------------
Costfun(pars_opt)

### -----------------------------------------------------------------------------------------------
## Code for first exploration of parameter values -------------------------------------------------
var1svec   <- seq(1,1.5,by=.05)
nvar1vec   <- length(var1svec)
var2vec    <- seq(0.001,0.05,by=0.002)
nvar2vec   <- length(var2vec)
# etc. more parameters can be added (adjusting loops below)
outcost <- matrix(nrow=nvar1vec,ncol=nvar2vec)
for (m in 1:nvar1vec)
{
  for (i in 1:nvar2vec)
  {
    pars_opt <- c(var2=nvar2vec[i],var1=var1svec[m])
    outcost[m,i] <- Costfun(pars_opt)
  }
}
minpos<-which(outcost==min(outcost),arr.ind=TRUE)
var1m<-var1svec[minpos[1]]
var2i<-nvar2vec[minpos[2]]

## Calling the optimization function
optpar <- pricefit(par=c(var1=var1m,var2=var2i), minpar=c(0.001,1),
                   maxpar=c(0.05,1.5),func=Costfun, npop=50, numiter=500,
                   centroid=3, varleft=1e-8)
### -----------------------------------------------------------------------------------------------



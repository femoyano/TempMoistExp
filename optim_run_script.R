#### optim_run_script.R

#### Documentations ===========================================================
# Script used to prepare settings and run parameter optimization
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

rm(list=ls()) # clear the work space

### Libraries =================================================================
require(deSolve)
require(FME)

### Define time units =========================================================
hour     <- 3600     # seconds in an hour
sec      <- 1        # seconds in a second!

# Model flags and other options ----------------------------------------------------------
flag.ads   <- 0  # simulate adsorption desorption rates
flag.mic   <- 0  # simulate microbial pool explicitly
flag.fcs   <- 1  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
flag.sew   <- 1  # calculate C_E and C_D concentration in water
flag.des   <- 1  # run using differential equation solver? If TRUE then t_step has no effect.
t_step     <- "hour"  # Model time step (as string). Important when using stepwise run.
t_save     <- "hour"  # save time step (only for stepwise model?)
tstep <- get(t_step)
tsave <- get(t_save)
ode.method <- "lsoda"  # see ode function

# Input Setup -----------------------------------------------------------------
input.all    <- read.csv(file.path("..", "Data", "NadiaTempMoist", "mtdata_model_input.csv"))
data.meas    <- read.csv(file.path("..", "Data", "NadiaTempMoist", "mtdata_co2.csv"))
data.samples <- read.csv(file.path("..", "Data", "NadiaTempMoist", "samples.csv"))
site.data.1  <- read.csv(file.path("..", "Data", "NadiaTempMoist", "site_Closeaux.csv"))
site.data.2  <- read.csv(file.path("..", "Data", "NadiaTempMoist", "site_BareFallow42p.csv"))

### Sourced required files ----------------------------------------------------
source("parameters.R")
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")

### Load and prepare input data -----------------------------------------------


## Calculate spatially changing variables and add to parameter list
b       <- 2.91 + 15.9 * clay                         # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000               # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
Rth     <- ps * (psi_sat / pars[["psi_Rth"]])^(1 / b) # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
fc      <- ps * (psi_sat / pars[["psi_fc"]])^(1 / b)  # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
Md       <- 200 * (100 * clay)^0.6 * pars[["pd"]] * (1 - ps) # [gC m-3] Mineral surface adsorption capacity in gC-equivalent (Mayes et al. 2012)

pars <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, b = b, psi_sat = psi_sat, Rth = Rth, fc = fc, Md = Md, end = end, spinup = spinup) # add all new parameters




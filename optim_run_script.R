#### optim_run_script.R

#### Documentations ===========================================================
# Script used to prepare settings and run parameter optimization
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### Libraries =================================================================
require("deSolve")
require("FME")
require("plyr")
require("reshape2")

### Define time units =========================================================
year     <- 31104000 # seconds in a year
hour     <- 3600     # seconds in an hour
sec      <- 1        # seconds in a second!

# Model flags and other options ----------------------------------------------------------
flag.ads   <- 0  # simulate adsorption desorption rates
flag.mic   <- 0  # simulate microbial pool explicitly
flag.fcs   <- 1  # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
flag.sew   <- 1  # calculate C_E and C_D concentration in water
flag.des   <- 0  # run using differential equation solver? If TRUE then t_step has no effect.
t_step     <- "hour"  # Model time step (as string). Important when using stepwise run.
t_save     <- "hour"  # save time step (only for stepwise model?)
tstep      <- get(t_step)
tsave      <- get(t_save)
ode.method <- "lsoda"  # see ode function
spinup     <- FALSE
eq.stop    <- FALSE   # Stop at equilibrium?

# Input Setup -----------------------------------------------------------------
input.all     <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "mtdata_model_input.csv"))
data.meas     <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "mtdata_co2.csv"))
data.samples  <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "samples.csv"))
site.data.mz  <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path("..", "Analysis", "NadiaTempMoist", "site_BareFallow42p.csv"))

### Sourced required files ----------------------------------------------------
source("parameters.R")
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")
source("initial_state.R")
source("optim_runModel.R")
source("optim_ModCost.R")
source("pars_optim_start_3.R")
source("pars_optim_lower_3.R")
source("pars_optim_upper_3.R")


### Obtain model cost --------------
ptm <- proc.time()
Cost <- ModCost(pars_optim)
proc.time() - ptm

### Check sensitivity of parameters ---------------
Sfun <- sensFun(ModCost, pars_optim)
summary(Sfun)
# Plot the parameter sensitivities through time
plot(Sfun, which = c("C_R"), xlab = hour, lwd = 2)
# Visually explore the correlation between parameter sensitivities:
pairs(Sfun, which = c("C_R"), col = c("blue", "green"))
ident <- collin(Sfun)
plot(ident, ylim=c(0,20))
ident[ident$N==7 & ident$collinearity<15,]

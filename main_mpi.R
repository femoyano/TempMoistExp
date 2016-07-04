#### optim_run_main.R

#### Documentations ===========================================================
# Script used to prepare settings before a run
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

RunMain <- function(pars, pars_calib) {
  
  ### ----------------------------------- ###
  ###       User Stup                     ###
  ### ----------------------------------- ###
  # Setup
  # -------- Model options ----------
  flag.ads  <- 0     # simulate adsorption desorption
  flag.mic  <- 1     # simulate microbial pool explicitly
  flag.fcs  <- 1     # scale C_P, C_A, C_Es, M to field capacity (with max at fc)
  flag.sew  <- 0     # calculate C_E and C_D concentration in water
  flag.dte  <- 0     # diffusivity temperature effect on/off
  flag.dce  <- 0     # diffusivity carbon effect on/off
  flag.mmu  <- 1     # michalis menten kinetics for uptake, else equal diffusion flux
  flag.mmr  <- 1     # microbial maintenance respiration
  dce.fun  <- 'exp'  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun <- 'hama' # Options: 'hama', 'cubic'
  
  # -------- Calibration options ----------
  # Cost calculation type.
  # Options: 'uwr' = unweighted residuals, 'wr' = wieghted residuals,  'rate.sd', 'rate.mean'...
  cost.type <- 'rate.mean' 
  # Which samples to run? E.g. samples.csv, samples_smp.csv, samples_4s.csv, samples_10s.csv
  sample_list_file <- 'samples_smp.csv' 
  
  
  ### ----------------------------------- ###
  ###      Non User Setup                 ###
  ### ----------------------------------- ###
  ### Libraries =================================================================
  # require(deSolve)
  # require(FME)
  # require(plyr)
  # require(reshape2)
  
  ### Define time variables =====================================================
  year     <- 31104000 # seconds in a year
  hour     <- 3600     # seconds in an hour
  sec      <- 1        # seconds in a second!
  
  # ----- fixed model setup ----
  t_step     <- "hour"  # Model time step (as string). Important when using stepwise run.
  t_save     <- "hour"  # save time step (only for stepwise model?)
  ode.method <- "lsoda"  # see ode function
  flag.des   <- 1       # Cannot be changed: model crashes when doing stepwise.
  tstep      <- get(t_step)
  tsave      <- get(t_save)
  spinup     <- FALSE
  eq.stop    <- FALSE
  
  # Input Setup -----------------------------------------------------------------
  input_path    <- file.path(".")  # ("..", "Analysis", "NadiaTempMoist")
  data.samples  <- read.csv(file.path(input_path, sample_list_file))
  input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
  obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
  site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
  site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))
  
  obs.accum <- obs.accum[obs.accum$sample %in% data.samples$sample,]
  
  ### Sourced required files ----------------------------------------------------
  source("flux_functions.R")
  source("Model_desolve.R")
  source("Model_stepwise.R")
  source("initial_state.R")
  source("ModCost_SR_TR.R")
  source("AccumCalc.R")
  source("ParsReplace.R")
  source("SampleRun.R")
  source("GetModelData.R")
  
  ## Run cost function
  ModCost(pars, pars_calib)
}

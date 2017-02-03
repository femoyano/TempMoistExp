#### Documentations ===========================================================
# Script used to prepare settings before a run
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

MainMpi <- function(pars_replace) {

  ### ----------------------------------- ###
  ###       User Stup                     ###
  ### ----------------------------------- ###
  list2env(setup, envir = .GlobalEnv)
  # Set cost_function specific for MPI runs
  cost_fun  <- "ModCost_mpi.R"
  pars_default <- read.csv(pars.default.file, row.names = 1)
  pars_default <- setNames(pars_default[[1]], row.names(pars_default))
  
  ### ----------------------------------- ###
  ###      Non User Setup                 ###
  ### ----------------------------------- ###
  ### Libraries =================================================================
  require(deSolve)
  require(FME)
  require(plyr)
  require(reshape2)
  
  ### Define time variables =====================================================
  year     <- 31104000 # seconds in a year
  hour     <- 3600     # seconds in an hour
  sec      <- 1        # seconds in a second!
  
  # ----- fixed model setup ----
  t_step     <- "hour"  # Model time step (as string). Important when using stepwise run.
  t_save     <- "hour"  # save time step (only for stepwise model?)
  ode.method <- "lsoda"  # see ode function
  flag_des   <- 1       # Cannot be changed: model crashes when doing stepwise.
  tstep      <- get(t_step)
  tsave      <- get(t_save)
  spinup     <- FALSE
  eq.stop    <- FALSE
  
  # Input Setup -----------------------------------------------------------------
  input_path    <- file.path("..", "input_data")
  input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
  obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
  site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
  site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))
  
  ### Sourced required files ----------------------------------------------------
  source("flux_functions.R", local = TRUE)
  source("Model_desolve.R", local = TRUE)
  source("initial_state.R", local = TRUE)
  source(cost_fun, local = TRUE)
  source("AccumCalc.R", local = TRUE)
  source("ParsReplace.R", local = TRUE)
  source("SampleRun.R", local = TRUE)
  
  # Add or replace parameters from the list of optimized parameters ------------------------
  names(pars_replace) <- colnames(pars_replace)
  pars <- ParsReplace(pars_replace, pars_default)
  ### Run all samples (in series since this is for mpi) ------------------------------------
  
  ## Run cost_function
  ModCost(pars)
}

# Run_script

# Documentation ================================================================
# Scipt for setting options and running the model
source("plot_results.R")
runscript <- TRUE # flag for the main file

# Choose to run spinup and/or transient run
spinup <- F
trans <- T

### General Setup ==============================================================
model.name  <- "EMDA"
spinup.data <- "Standard1"
trans.data  <- "LitterInc1"

### ============================================================================
spinup.name <- paste(model.name, spinup.data, sep="_")
trans.name  <- paste(model.name, trans.data, sep="_")

### Spinup run =================================================================
if(spinup) {
  input.file  <- paste("input_", spinup.data, ".csv", sep="")
  run.name    <- spinup.name
  eq.stop     <- TRUE       # Stop at equilibrium?
  eq.md       <- 20         # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.
  t.max.spin  <- 800000     # maximum run time for spinup runs (in t_step units)
  t_step      <- "hour"     # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- "month"    # time unit at which to save output. Cannot be less than t_step
  source("initial_state.r") # Loads initial state variable values
  source("main.R")
  out$TOC <- rowSums(out[,2:7])
  print(tail(out, 1))
  assign(run.name, out)
  save(list=run.name, file = paste("../OutputData/", run.name, "_spinup.Rdata", sep=""))
  PlotResults(out)
}

### Transient run ==============================================================
if(trans) {
  input.file  <- paste("input_", trans.data, ".csv", sep="")
  run.name    <- trans.name
  load(paste("../OutputData/", spinup.name, "_spinup.Rdata", sep=""))
  rm(initial_state)
  init <- tail(get(spinup.name), 1)
  initial_state <- c(
    PC  = init$PC[1]  ,
    SCw = init$SCb[1] ,
    SCs = init$SCs[1] ,
    ECb = init$ECb[1] ,
    ECm = init$ECm[1] ,
    ECs = init$ECs[1] ,
    CO2 = 0
  )
  spinup      <- FALSE      # If TRUE then spinup run and data will be recylced.
  t_step      <- "hour"     # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- "month"    # time unit at which to save output. Cannot be less than t_step
  source("main.R")
  out$TOC <- rowSums(out[,2:7])
  # assign run name and save
  assign(run.name, out)
  save(list=run.name, file = paste("../OutputData/", run.name, "_trans.Rdata", sep=""))
  print(tail(out, 1))
  PlotResults(out)
}

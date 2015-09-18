### Run_script
rm(list=ls())

### User Setup =================================================================
spin <- 0
trans <- 1
model.name  <- "EDA"
site.name   <- "Wetzstein"
spinup.data <- "WetzsteinSM08"
trans.data  <- "WetzsteinSM08"

t.max.spin     <- 300000    # maximum run time for spinup runs (in t_step units)
t_save_spinup  <- "day"    # time interval at which to save spinup output. Same or larger than t_step.
t_save_trans   <- "hour"    # time unit at which to save output. Cannot be less than t_step
eq.stop.spinup <- FALSE     # Stop spinup at equilibrium?
eq.md          <- 20        # maximum difference for equilibrium conditions [in g PC m-3]. spinup run stops if difference is lower.

### Optional Setup =============================================================

input.path        <- file.path("..", "InputData")
spinup.input.file <- file.path(input.path, paste("input_", spinup.data, ".csv", sep=""))
trans.input.file  <- file.path(input.path, paste("input_", trans.data, ".csv", sep=""))
site.file         <- file.path(input.path, paste("input_site_", site.name, ".csv", sep=""))

spinup.name <- paste(model.name, spinup.data, sep="_")
trans.name  <- paste(model.name, trans.data, sep="_")

### Non User Setup =============================================================
runscript <- TRUE # flag for the main file

### Spinup run =================================================================
if(spin) {
  input.file  <- spinup.input.file
  run.name    <- spinup.name
  spinup      <- TRUE      # If TRUE then spinup run and data will be recylced.
  eq.stop     <- eq.stop.spinup
  t_step      <- "hour" # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- t_save_spinup
  source("initial_state.r") # Loads initial state variable values
  source("main.R")
  out$TOC <- rowSums(out[,2:7])
  print(tail(out, 1))
  assign(run.name, out)
  save(list=run.name, file = paste("../OutputData/", run.name, "_spinup.Rdata", sep=""))
}

### Transient run ==============================================================
if(trans) {
  input.file  <- trans.input.file
  run.name    <- trans.name
  spinup      <- FALSE      # If TRUE then spinup run and data will be recylced.
  t_step      <- "hour"     # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- t_save_trans
  eq.stop     <- FALSE       # Stop at equilibrium?
  load(paste("../OutputData/", spinup.name, "_spinup.Rdata", sep=""))
#   load(paste("../OutputData/", trans.name, "_trans.Rdata", sep=""))
  if(exists("initial_state")) rm(initial_state)
  init <- tail(get(spinup.name), 1)
  initial_state <- c(
    PC  = init$PC[1]  ,
    SCw = init$SCw[1] ,
    SCs = init$SCs[1] ,
    ECb = init$ECb[1] ,
    ECm = init$ECm[1] ,
    ECs = init$ECs[1] ,
    CO2 = 0
  )
  source("main.R")
  out$TOC <- rowSums(out[,2:7])
  # assign run name and save
  assign(run.name, out)
  save(list=run.name, file = paste("../OutputData/", run.name, "_trans.Rdata", sep=""))
  print(tail(out, 1))
}

# Plot results
source("PlotResults.R")
if(spin) PlotResults(get(spinup.name), "month", path = "../Plots/Spinup/", spinup.name)
if(trans) PlotResults(get(trans.name), "day", path = "../Plots/Trans/", trans.name)

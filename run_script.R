# Run_script

# Documentation
# Scipt for setting options and running the model

runscript   <- TRUE
spinup <- F
trans <- T

### Spinup run =================================================================
if(spinup) {
  run.name <- "spinup_DAnoM"
  eq.stop     <- FALSE      # Stop at equilibrium?
  eq.md       <- 1          # maximum difference for equilibrium conditions [in mgC gSoil-1]. spinup run stops if difference is lower.
  t.max.spin  <- 500000     # maximum run time for spinup runs (in t_step units)
  t_step      <- "hour"     # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- "month"    # time unit at which to save output. Cannot be less than t_step
  source("initial_state.r") # Loads initial state variable values
  source("main.R")
  out$TOC <- rowSums(out[,2:7])
  print(tail(out, 1))
  assign(run.name, tail(out,100))
  save(list=run.name, file = paste("../OutputData/", run.name)
}

### Transient run ==============================================================
if(trans) {
#   init <- tail(out.spin, 1)
#   initial_state <- c(
#     init[2] , # [gC m-3] labile carbon 
#     init[3] , # [gC m-3] soluble carbon in bulk 
#     init[4] , # [gC m-3] sorbed SC
#     init[5] , # [gC m-3] enzymes in bulk 
#     init[6] , # [gC m-3] enzymes at microbe 
#     init[7] , # [gC m-3]sorbed EC
#     init[8]   # [gC] microbial carbon 
#   )
  run.name <- "litt_incr_0.5_100y_DAnoM"
  source("initial_state.r") # Loads initial state variable values
  eq.stop     <- FALSE      # Stop at equilibrium?
  eq.md       <- 1          # maximum difference for equilibrium conditions [in mgC gSoil-1]. spinup run stops if difference is lower.
  spinup      <- FALSE      # If TRUE then spinup run and data will be recylced.
  t_step      <- "hour"     # model time step (as string). Keep "hour" for correct equilibrium values
  t_save      <- "month"    # time unit at which to save output. Cannot be less than t_step
  source("main.R")
  out$TOC <- rowSums(out[,2:7])
  print(tail(out, 1))
  assign(run.name, out)
  save(list=run.name, file = paste("../OutputData/", run.name)
  agg.time <- year
  out.agg <- aggregate(out, by=list(x=ceiling(out[,1]*tstep/agg.time)), FUN=mean)
  source("plot_results.R")
}

rm(list=ls())
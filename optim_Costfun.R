#### Costfun.R

#### Documentation =============================================================
# Simulation of soil C dynamics.
# This script runs the model and then calculates the model cost
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

# Read in the data (input and measured output)

data_TM <- read.csv(file = "../Data/NadiaTempMoist/mtdata_co2.csv")
input_TM <- read.csv(file = "../Data/NadiaTempMoist/mtdata_model_input.csv")
samples <- read.csv("../Data/NadiaTempMoist/samples.csv")

# Run model for all samples and obtain aggragated results
for (i in unique(data_TM$sample)) {
  input <- 
  outtimes <-   
}

  
outtimes    <- as.vector(data$time) # define output times to be data times



Costfun <- function(pars_opt) {

  out <- Mod_TMdata(pars_opt)
  cost <- modCost(model = out, obs = data)
      outtimes    <- as.vector(data$time) # define output times to be data times
    init_trans  <- GetInitial(tail(spinout, 1)) # obtain initial values
    if(flag.des) { # if true, run the differential equation solver
      out <- ode(initial_state, times, Model_desolve, pars, method = ode.method)
    } else { # else run the stepwise simulation
      out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, pars)
    } # get model results by calling ode(init_values, outtimes, Model_desolve, pars)
    C_R.rate <- c(0, diff(out[8]))
    C_R.rate <- C_R.rate # make necessary unit conversion here
    costt       <- sum((C_R.rate - data$C_R)^2)
    return(costt)
}
  
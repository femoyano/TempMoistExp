### Define the function that runs model for each sample --------------------------------
SampleRun <- function(pars, sample.data, input) {

  source("prepare_input.R", local=TRUE)
  
  if(flag.des) { # if true, run the differential equation solver
    out <- ode(initial_state, times, Model_desolve, parameters, method = ode.method) # , App_Isl = Approx_I_sl, App_Iml = Approx_I_ml, App_T = Approx_temp, App_M = Approx_moist
  } else { # else run the stepwise simulation
    out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, parameters)
  }
  
  out[, 'C_R'] <- out[, 'C_R'] / (parameters[["depth"]] * (1 - parameters[["ps"]]) * parameters[["pd"]] * 1000)  # converting to gC respired per kg soil

  out <- cbind(out, sample = rep(sample.data$sample, nrow(out)))
  
  return(out)
}

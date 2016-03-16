### Define the function that runs model for each sample --------------------------------
SampleCost <- function(pars, sample.data, input, meas) {
  
  source("prepare_input.R", local=TRUE)
  
  if(flag.des) { # if true, run the differential equation solver
    out <- ode(initial_state, times, Model_desolve, parameters, method = ode.method) # , App_Isl = Approx_I_sl, App_Iml = Approx_I_ml, App_T = Approx_temp, App_M = Approx_moist
  } else { # else run the stepwise simulation
    out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, parameters)
  }
  
  out[, 'C_R'] <- out[, 'C_R'] / (parameters[["depth"]] * (1 - parameters[["ps"]]) * parameters[["pd"]] * 1000)  # converting to gC respired per kg soil
  
  # out <- cbind(out, rep(sample.data$sample, nrow(out)))
  out <- as.data.frame(out)
  
  ## Calculate accumulated values and cost -----------------------------------------------
  C_R_m <- NULL
  for (i in 1:nrow(meas)) {
    t1 <- meas$hour[i]
    t0 <- t1 - meas$time_accum[i]
    C_R_m[i] <- out$C_R[out$time == t1] - out$C_R[out$time == t0]
  }
  mod <- data.frame(time = meas$hour, C_R = C_R_m)
  obs <- data.frame(name = rep("C_R", nrow(meas)), time = meas$hour, C_R = meas$C_R, stderr = meas$sd)
  name <- paste("cost", sample.data$sample[1], sep="")
  return(assign(name, modCost(model=mod, obs=obs, y = "C_R", err = "stderr")))
}

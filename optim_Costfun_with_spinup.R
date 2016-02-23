#### Costfun.R

#### Documentation =============================================================
# Simulation of soil C dynamics.
# This script runs the model and then calculates the model cost
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

Costfun <- function(pars_opt)
  
  for(n in names(pars_opt)) pars[[n]] <- pars_opt[[n]]
  
  {with(as.list(pars),
        {
          # First run a spinup to get initial values --------
          # Define input interpolation functions
          Approx_I_sl  <- s.Approx_I_sl
          Approx_I_ml  <- s.Approx_I_ml
          Approx_temp  <- s.Approx_temp
          Approx_moist <- s.Approx_moist
          times <- s.times
          if(exists("initial_state")) rm(initial_state)
          source("initial_state.R")
          if(flag.des) { # if true, run the differential equation solver
            spinout <- ode(initial_state, times, Model_desolve, pars, method = ode.method)
          } else { # else run the stepwise simulation
            spinout <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, pars)
          }
          
          # Next run the transient --------------------------
          # Define input interpolation functions
          Approx_I_sl <- t.Approx_I_sl
          Approx_I_ml <- t.Approx_I_ml
          Approx_temp       <- t.Approx_temp
          Approx_moist      <- t.Approx_moist
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
        })
  }
  
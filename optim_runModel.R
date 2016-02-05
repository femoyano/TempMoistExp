# Define model run function here
runModel <- function(pars) {
  
  out <- data.frame(colnames(c("time", "C_P", "C_D", "C_A", "C_Ew", "C_Em", "C_M", "C_R", "temp", "moist")))
  
  runSamples <- function() {
    
    pars <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, b = b, psi_sat = psi_sat, Rth = Rth, fc = fc, Md = Md, end = end, spinup = spinup) # add all new parameters
    
    for (i in data.samples$sample[data.samples$site == "bare_fallow"]) {
      
      # Get the subset of input for the sample
      input.data <- input.all[input.all$sample == i]
      
      # Extract data
      times_input <- input.data$hour        # time of input data
      temp        <- input.data$temp       # [K] soil temperature
      moist       <- input.data$moist      # [m3 m-3] specific soil volumetric moisture
      I_ml        <- input.data$litter_met / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate
      I_sl        <- input.data$litter_str / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate
      
      # Define input interpolation functions
      Approx_I_sl  <- approxfun(times_input, I_sl , method = "linear", rule = 2)
      Approx_I_ml  <- approxfun(times_input, I_ml , method = "linear", rule = 2)
      Approx_temp  <- approxfun(times_input, temp_data  , method = "linear", rule = 2)
      Approx_moist <- approxfun(times_input, moist_data , method = "linear", rule = 2)
      
      if(flag.des) { # if true, run the differential equation solver
        out <- ode(initial_state, times, Model_desolve, pars, method = ode.method)
      } else { # else run the stepwise simulation
        out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, pars)
      }
    }    
  }
  
  site.data  <- site.data.1
  sand   <- site.data$sand  # [g g^-1] clay fraction values 
  clay   <- site.data$clay  # [g g^-1] sand fraction values 
  silt   <- site.data$silt  # [g g^-1] silt fraction values 
  ps     <- site.data$ps    # [m^3 m^-3] soil pore space
  depth  <- site.data$depth # [m] soil depth
  
  ## Calculate spatially changing variables and add to parameter list
  b       <- 2.91 + 15.9 * clay                         # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
  psi_sat <- exp(6.5 - 1.3 * sand) / 1000               # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
  Rth     <- ps * (psi_sat / pars[["psi_Rth"]])^(1 / b) # [m3 m-3] Threshold relative water content for mic. respiration (water retention formula from Campbell 1984)
  fc      <- ps * (psi_sat / pars[["psi_fc"]])^(1 / b)  # [m3 m-3] Field capacity relative water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
  Md       <- 200 * (100 * clay)^0.6 * pars[["pd"]] * (1 - ps) # [gC m-3] Mineral surface adsorption capacity in gC-equivalent (Mayes et al. 2012)
  
  initial_state <- ???

  
}
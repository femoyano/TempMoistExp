# Define model run function here
ModCost <- function(pars_optim) {
  
  ### Define the function to run model ---------------------------------------------------
  runSamples <- function(site.data, pars, site, data.samples, input.all, all.out) {
    
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
    Md      <- 200 * (100 * clay)^0.6 * pars[["pd"]] * (1 - ps) # [gC m-3] Mineral surface adsorption capacity in gC-equivalent (Mayes et al. 2012)
    
    # Add new parameters to pars
    pars <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, depth = depth, b = b, 
              psi_sat = psi_sat, Rth = Rth, fc = fc, Md = Md)
    
    # Set initial states
    if (site == "bare_fallow") toc <- pars[["TOC_bf"]] else if (site == "maize") toc <- pars[["TOC_mz"]] else stop("eh?")
    TOC <- toc * 1000000 * pars[["pd"]] * (1 - pars[["ps"]]) * pars[["depth"]]
    initial_state[["C_P"]]  <- TOC * (1 - pars[["f_CA"]])
    initial_state[["C_D"]]  <- TOC * 0.001
    initial_state[["C_A"]]  <- TOC * pars[["f_CA"]]
    initial_state[["C_Ew"]] <- TOC * 0.001
    initial_state[["C_Em"]] <- TOC * 0.001
    initial_state[["C_M"]]  <- TOC * 0.01
    initial_state[["C_R"]]  <- 0
    
    for (i in data.samples$sample[data.samples$site == site]) {
      
      # Get the subset of input for the sample
      input.data <- input.all[input.all$sample == i,]
      
      # Extract data
      times_input <- input.data$hour        # time of input data
      temp        <- input.data$temp       # [K] soil temperature
      moist       <- input.data$moist      # [m3 m-3] specific soil volumetric moisture
      I_ml        <- input.data$litter_met / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate
      I_sl        <- input.data$litter_str / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate
      
      # Obtain data times: start and end
      start <- times_input[1]
      end   <- tail(times_input, 1)
      times <- seq(start, end)
      
      # Define input interpolation functions
      Approx_I_sl  <<- approxfun(times_input, I_sl , method = "linear", rule = 2)
      Approx_I_ml  <<- approxfun(times_input, I_ml , method = "linear", rule = 2)
      Approx_temp  <<- approxfun(times_input, temp  , method = "linear", rule = 2)
      Approx_moist <<- approxfun(times_input, moist , method = "linear", rule = 2)
      
      if(flag.des) { # if true, run the differential equation solver
        out <- ode(initial_state, times, Model_desolve, pars, method = ode.method) # , App_Isl = Approx_I_sl, App_Iml = Approx_I_ml, App_T = Approx_temp, App_M = Approx_moist
      } else { # else run the stepwise simulation
        out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, pars)
      }
      
      out <- as.data.frame(out)
      out$C_R <- out$C_R / (pars[["depth"]] * (1 - pars[["ps"]]) * pars[["pd"]] * 1000)  # converting to gC respired per kg soil
      out$sample <- i
      all.out <- rbind(all.out, out)
    }
    return(all.out)
  }
  # --------------------------------------------------------------------------------------
  
  # Add or replace parameters from the list of optimized parameters
  for(n in names(pars_optim)) pars[[n]] <- pars_optim[[n]]
  # Replace param values where assignment is required
  pars[["E_r_ed"]] <- pars[["E_r_md"]] <- pars[["E_VD"]] <- pars[["E_V"]]
  pars[["E_KD"]] <- pars[["E_K"]]
  if("E_k" %in% names(pars_optim)) pars[["E_ka"]] <- pars[["E_kd"]] <- pars[["E_k"]]
  pars[["D_e0"]] <- pars[["D_d0"]] / 10
#   TOC_bf <- 0.007  # gC gSoil-1
#   TOC_mz <- 0.013  # gC gSoil-1
#   f_CA <- 0.7      # both soils (bare fallow and maize(Closeaux)) has the same fraction of clay+silt-C to total C
  

  # Create a data frame to hold output
  all.out <- data.frame(colnames(c("time", "C_P", "C_D", "C_A", "C_Ew", "C_Em", "C_M", "C_R", "temp", "moist", "sample")))
  
  ### Run bare fallow samples ------------------------------------------------------------
  
  all.out <- runSamples(site.data.bf, pars, "bare_fallow", data.samples, input.all, all.out)
  
  ### Run bare fallow samples ------------------------------------------------------------
  
  all.out <- runSamples(site.data.mz, pars, "maize", data.samples, input.all, all.out)
  
  ### calculate accumulated fluxes as measured and pass to modCost function --------------

  for (i in 1:nrow(data.meas)) {
    t1 <- data.meas$hour[i]
    t0 <- t1 - data.meas$time_inc[i]
    s  <- data.meas$sample[i]
    data.meas$C_R_m[i] <- all.out$C_R[all.out$sample == s & all.out$time == t1] - all.out$C_R[all.out$sample == s & all.out$time == t0]
  }
  
  obs <- subset(data.meas, select = c("hour", "C_R"))
  mod <- subset(data.meas, select = c("hour", "C_R_m"))
  mod$C_R <- mod$C_R_m
  mod$C_R_m <- NULL
  rm(data.meas)
  
  return(modCost(model=mod, obs=obs, x="hour"))
}

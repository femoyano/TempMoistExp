# Define model run function here
ModCost <- function(pars_optim) {
  
  ### Define the function to run model ---------------------------------------------------
  runSamples <- function(pars, site, data.samples, input.all, all.out) {
    
    if (site == "bare_fallow") {
      site.data <- site.data.bf
    } else if (site == "maize") {
      site.data <- site.data.mz
    } else stop("wrong site name?")
    
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
    D_d0    <- pars[["D_0"]]        # Diffusion conductance for dissolved C
    D_e0    <- pars[["D_0"]] / 10   # Diffusion conductance for enzymes
    
    # Add new parameters to pars
    parameters <- c(pars, sand = sand, silt = silt, clay = clay, ps = ps, depth = depth, b = b, 
                    psi_sat = psi_sat, Rth = Rth, fc = fc, Md = Md, D_d0 = D_d0, D_e0 = D_e0)
    
    # Set initial states
    if (site == "bare_fallow") {
      toc <- parameters[["TOC_bf"]]
      f_CA <- parameters[["f_CA_bf"]] 
      } else if (site == "maize") {
        toc <- parameters[["TOC_mz"]]
        f_CA <- parameters[["f_CA_mz"]] }
    
    TOC <- toc * 1000000 * parameters[["pd"]] * (1 - parameters[["ps"]]) * parameters[["depth"]]
    initial_state[["C_P"]]  <- TOC * (1 - f_CA)
    initial_state[["C_D"]]  <- TOC * 0.001
    initial_state[["C_A"]]  <- TOC * f_CA
    initial_state[["C_Ew"]] <- TOC * 0.001
    initial_state[["C_Em"]] <- TOC * 0.001
    initial_state[["C_M"]]  <- TOC * 0.01
    initial_state[["C_R"]]  <- 0
    
    runSingle <- function(sample, all.out) {
      # Get the subset of input for the sample
      input.data <- input.all[input.all$sample == sample,]
      
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
        out <- ode(initial_state, times, Model_desolve, parameters, method = ode.method) # , App_Isl = Approx_I_sl, App_Iml = Approx_I_ml, App_T = Approx_temp, App_M = Approx_moist
      } else { # else run the stepwise simulation
        out <- Model_stepwise(spinup, eq.stop, times, tstep, tsave, initial_state, parameters)
      }
      
      out[, 'C_R'] <- out[, 'C_R'] / (parameters[["depth"]] * (1 - parameters[["ps"]]) * parameters[["pd"]] * 1000)  # converting to gC respired per kg soil
      all.out <- rbind(all.out, cbind(out, rep(sample, nrow(out))))
    }
    
    for (i in data.samples$sample[data.samples$site == site]) {
      all.out <- runSingle(i, all.out)
    }
    return(all.out)
  }
  
  # Add or replace parameters from the list of optimized parameters ----------------------
  for(n in names(pars_optim)) pars[[n]] <- pars_optim[[n]]
  # Replace param values where assignment is required
  pars[["E_r_ed"]] <- pars[["E_r_md"]] <- pars[["E_VD"]] <- pars[["E_V"]]
  pars[["E_KD"]] <- pars[["E_K"]]
  if("E_k" %in% names(pars_optim)) pars[["E_ka"]] <- pars[["E_kd"]] <- pars[["E_k"]]
  
  # Create a matrix to hold output
  all.out <- matrix(ncol=9, nrow=0)
  colnames(all.out) <- c("time", "C_P", "C_D", "C_A", "C_Ew", "C_Em", "C_M", "C_R", "sample")
  
  ### Run both soils in parallel ---------------------------------------------------------
  ptm <- proc.time()
  all.out <- foreach(soil=c('bare_fallow', 'maize'), .combine = 'rbind') %dopar% {
    all.out <- runSamples(pars, soil, data.samples, input.all, all.out)
  }
  print(cat('t1', proc.time() - ptm))
  
  ### calculate accumulated fluxes as measured and pass to modCost function --------------
 
  # Parallel --------------------------------
  
  ptm <- proc.time()
  
  accumFun <- function(j, all.out) {
    C_R_m <- NA
    C_R_o <- NA
    time <- NA
    snum <- seq((j-1)*x+1,j*x)
    if (j == cores) snum <- seq((j-1)*x+1, nrow(data.meas))
    it <- 1
    for (i in snum) {
      t1 <- data.meas$hour[i]
      t0 <- t1 - data.meas$time_inc[i]
      s  <- data.meas$sample[i]
      C_R_m[it] <- all.out[all.out[,'sample'] == s & all.out[,'time'] == t1, 'C_R'] - all.out[all.out[,'sample'] == s & all.out[,'time'] == t0, 'C_R'] 
      C_R_o[it] <- data.meas$C_R[i]
      time[it] <- data.meas$hour[i]
      it <- it+1
    }
    return(cbind(C_R_m, C_R_o, time))
  }

  cores <- getDoParWorkers()
  x <- floor(nrow(data.meas) / cores)
  
  out <- foreach (j=1:cores, combine = 'rbind') %dopar% {
    accumFun(j, all.out)
  }

  out <- as.data.frame(out)

  obs <- subset(out, select = c("time", "C_R_o"))
  mod <- subset(out, select = c("time", "C_R_m"))
  mod$C_R <- mod$C_R_m
  mod$C_R_m <- NULL
  obs$C_R <- obs$C_R_o
  obs$C_R_o <- NULL
  
  print(cat('t2', proc.time() - ptm))
  
  return(modCost(model=mod, obs=obs, x="time"))
  
}
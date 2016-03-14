# prepare_input.R
# Prepares input reuqired for each sample run.

if (sample.data$site == "bare_fallow") {
  site.data <- site.data.bf
  f_CA <- pars[["f_CA_bf"]] 
} else if (sample.data$site == "maize") {
  site.data <- site.data.mz
  f_CA <- pars[["f_CA_mz"]] 
} else stop("no site name match in prepare_input.R")

sand   <- site.data$sand  # [g g^-1] clay fraction values 
clay   <- site.data$clay  # [g g^-1] sand fraction values 
silt   <- site.data$silt  # [g g^-1] silt fraction values 
ps     <- site.data$ps    # [m^3 m^-3] soil pore space
depth  <- site.data$depth # [m] soil depth
toc    <- site.data$toc   # [gC gSoil-1]

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

TOC <- toc * 1000000 * parameters[["pd"]] * (1 - parameters[["ps"]]) * parameters[["depth"]]
initial_state[["C_P"]]  <- TOC * (1 - f_CA)
initial_state[["C_D"]]  <- TOC * 0.001
initial_state[["C_A"]]  <- TOC * f_CA
initial_state[["C_Ew"]] <- TOC * 0.001
initial_state[["C_Em"]] <- TOC * 0.001
initial_state[["C_M"]]  <- TOC * 0.01
initial_state[["C_R"]]  <- 0

# Extract data
times_input <- input$hour        # time of input data
temp        <- input$temp       # [K] soil temperature
moist       <- input$moist      # [m3 m-3] specific soil volumetric moisture
I_ml        <- input$litter_met / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate
I_sl        <- input$litter_str / hour * tstep # [mgC m^-2 tstep^-1] convert litter input rates to the model rate

# Obtain data times: start and end
start <- times_input[1]
end   <- tail(times_input, 1)
times <- seq(start, end)

# Define input interpolation functions
Approx_I_sl  <<- approxfun(times_input, I_sl , method = "linear", rule = 2)
Approx_I_ml  <<- approxfun(times_input, I_ml , method = "linear", rule = 2)
Approx_temp  <<- approxfun(times_input, temp  , method = "linear", rule = 2)
Approx_moist <<- approxfun(times_input, moist , method = "linear", rule = 2)

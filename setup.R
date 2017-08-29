setup <- list(
  runinfo = "Description of this run",
  savetxt = "", # this apends to output file
  # savetxt   <- paste("_mic", flag_mic, "_fcs", flag_fcs, "_sew", flag_sew,
  #                  "_dte", flag_dte, "_dce", flag_dce, "_", dce_fun, "_", diff_fun,
  #                  "_", mf.method, "_", cost.type, "-", sep = "")

  # -------- Model options ----------
  flag_mic  = 1 ,  # simulate microbial pool explicitly
  flag_fcs  = 0 ,  # scale C_P and M to field capacity (with max at fc)
  flag_sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag_dte  = 0 ,  # diffusivity temperature effect on/off
  flag_dce  = 0 ,  # diffusivity carbon effect on/off
  flag_mmr  = 1 ,  # activate microbial maintenance respiration
  dce_fun   = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff_fun  = "power" ,  # Options: 'hama', 'cubic'
  dec_fun   = "MM" , # One of: 'MM', '2nd', '1st'
  upt_fun   = "1st" , # One of: 'MM', '2nd', '1st'

  # -------- Calibration options ----------
  run.test  = 0 ,  # run model cost once as test?
  run.sens  = 0 ,  # run FME sensitivity analysis?
  run.mfit  = 1 ,  # run modFit for optimization?
  run.mcmc  = 0 ,  # run Markov Chain Monte Carlo?
  # Observation error: name of column with error values:
  # 'C_R_gm', 'C_R_sdnorm', 'C_R_sd001', 'C_R_sd005', 'C_R_sd01', 'one' or NULL to use weight.
  SRerror  = 'one'  ,
  TRerror  = NULL  ,
  # Weight for cost:  only if error is NULL. One of 'none', 'mean', 'std'.
  SRweight = 'none' ,
  TRweight = 'none' ,
  # Scale variables? TRUE or FALSE
  scalevar = FALSE   ,
  # Choose method for modFit
  mf.method = "Nelder-Mead"     ,
  # Choose cost function
  cost_fun  = "ModCost.R" ,
  # Choose MCMC options:
  niter  = 30000 ,  # number of iterations
  jfrac  = 200    ,  # fraction of parameters size for jumps
  burnin = 10000  ,  # length of burn in
  udcov  = 500    ,  # iteration period for updating covariance matrix

  # -------- Parameter options ----------
  # csv file with default parameters
  pars.default.file = "parsets/pars5.csv" ,
  # csv file with initial valeus for optimized parameters
  pars.optim.file   = "parsets/"    ,
  # csv file with bounds for optimized parameters
  pars.bounds.file  = "parsets/" ,
  # for single runs (run_smp.R)
  pars.new.file = 'parsets/pars5.csv'  ,
  # for mpi runs
  pars.mpi.file = 'parsets/' ,
  # For mupliple runs using command line input
  pars.mult.file = "parsets/"
)

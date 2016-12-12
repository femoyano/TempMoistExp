setup <- list(
  runinfo = "Description of this run",
  savetxt = "", # this apends to output file
  # savetxt   <- paste("_mic", flag.mic, "_fcs", flag.fcs, "_sew", flag.sew,
  #                  "_dte", flag.dte, "_dce", flag.dce, "_", dce.fun, "_", diff.fun,
  #                  "_", mf.method, "_", cost.type, "-", sep = "")
  
  # -------- Model options ----------
  flag.mic  = 1 ,  # simulate microbial pool explicitly
  flag.fcs  = 0 ,  # scale C_P and M to field capacity (with max at fc)
  flag.sew  = 0 ,  # calculate C_E and C_D concentration in water
  flag.dte  = 0 ,  # diffusivity temperature effect on/off
  flag.dce  = 0 ,  # diffusivity carbon effect on/off
  flag.mmu  = 1 ,  # michalis menten kinetics for uptake, else equal diffusion flux
  flag.mmr  = 1 ,  # microbial maintenance respiration
  dce.fun   = "exp"   ,  # diffusivity carbon function: 'exp' = exponential, 'lin' = linear
  diff.fun  = "hama" ,  # Options: 'hama', 'cubic'
  
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
  cost.fun  = "ModCost_SR.R" ,
  # Choose MCMC options:
  niter  = 100000 ,  # number of iterations
  jfrac  = 200    ,  # fraction of parameters size for jumps
  burnin = 30000  ,  # length of burn in
  udcov  = 500    ,  # iteration period for updating covariance matrix 
  
  # -------- Parameter options ----------
  # csv file with default parameters
  pars.default.file = "parsets/parset_dev7_all.csv" ,
  # csv file with initial valeus for optimized parameters
  pars.optim.file   = "parsets/pars_mcmc4.csv"      ,
  # csv file with bounds for optimized parameters
  pars.bounds.file  = "parsets/pars_bounds_dev7_3.csv" ,
  # for single runs (run_smp.R)
  pars.new.file = 'parsets/pars_1124-0251runsmp4_round.csv'  ,
  # for mpi runs
  pars.mpi.file = 'parsets/' ,
  # For mupliple runs using command line input
  pars.mult.file = "parsets/"
)

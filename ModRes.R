# Define model run function here
ModRes <- function(pars_optim) {
  
  # Source the model preparing each sample for model run.
  source("SampleCost.R")

  # Add or replace parameters from the list of optimized parameters ----------------------
  for(n in names(pars_optim)) pars[[n]] <- pars_optim[[n]]
  # Replace param values where assignment is required
  pars[["E_r_ed"]] <- pars[["E_r_md"]] <- pars[["E_VD"]] <- pars[["E_V"]]
  pars[["E_KD"]] <- pars[["E_K"]]
  if("E_k" %in% names(pars_optim)) pars[["E_ka"]] <- pars[["E_kd"]] <- pars[["E_k"]]
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------
  ptm <- proc.time()
  
  all.cost <- foreach(i = data.samples$sample, .packages = c("deSolve")) %dopar% {
    SampleCost(pars, data.samples[data.samples$sample==i, ],
               input.all[input.all$sample==i, ],
               data.meas[data.meas$sample == i, ])
  }

  print(cat('t1', proc.time() - ptm))
  
  # Create a vector of all (un)weighted residuals
  Res <- NULL
  ResW <- NULL
  for(i in 1:length(all.cost)) {
    Res <- c(Res, all.cost[[i]]$residuals$res.unweighted)
    ResW <- c(Res, all.cost[[i]]$residuals$res)
  }
  
  return(Resid = list(Res, ResW))
}
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
  
  all.cost <- foreach(i = data.samples$sample, .export = c("site.data.bf", "site.data.mz", "SampleCost"), .packages = c("deSolve")) %dopar% {
    SampleCost(pars, data.samples[data.samples$sample==i, ],
               input.all[input.all$sample==i, ],
               data.meas[data.meas$sample == i, ])
  }

  print(cat('t1', proc.time() - ptm))
  
  # Concatenate residuals
  Res <- NULL
  for(i in 1:length(all.cost)) {
    if(cost.type == "wr") Res <- c(Res, all.cost[[i]]$residuals$res) else
      if(cost.type == "uwr") Res <- c(Res, all.cost[[i]]$residuals$res.unweighted) else stop("wrong cost.type")
  }
  
  return(Res)
}
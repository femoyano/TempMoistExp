# ModRes.R
# This model calculates the model residuals
# This version calls SampleCost.R

ModRes <- function(pars_optim) {

  # Add or replace parameters from the list of optimized parameters ----------------------
  pars <- ParsReplace(pars_optim, pars)
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------

  all.cost <- foreach(i = data.samples$sample,
                      .export = c(ls(), "pars"),
                      .packages = c("deSolve")) %dopar% {
    SampleCost(pars, data.samples[data.samples$sample==i, ],
               input.all[input.all$sample == i, ],
               obs.accum[obs.accum$sample == i, ])
  }

  # Concatenate residuals
  Res <- NULL
  for(i in 1:length(all.cost)) {
    if(cost.type == "wr") Res <- c(Res, all.cost[[i]]$residuals$res) else
      if(cost.type == "uwr") Res <- c(Res, all.cost[[i]]$residuals$res.unweighted) else stop("wrong cost.type")
  }
  
  return(Res)
}
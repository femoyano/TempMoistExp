# ModRes.R
# This model calculates the model residuals
# This version calls SampleCost.R

ModRes <- function(pars_optim) {

  # Add or replace parameters from the list of optimized parameters ----------------------
  pars <- ParsReplace(pars_optim, pars)
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------
  ptm <- proc.time()
  
  all.cost <- foreach(i = data.samples$sample,
                      .export = c("site.data.bf", "site.data.mz", "SampleCost",
                                  "pars", "data.samples", "input.all", "obs.accum", 
                                  "initial_state", "hour", "tstep"),
                      .packages = c("deSolve")) %dopar% {
    SampleCost(pars, data.samples[data.samples$sample==i, ],
               input.all[input.all$sample == i, ],
               obs.accum[obs.accum$sample == i, ])
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
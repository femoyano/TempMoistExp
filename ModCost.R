# ModCost.R
# This model calculates the model residuals
# This version calls SampleRun.R

ModCost <- function(pars_optim) {

  # Add or replace parameters from the list of optimized parameters ----------------------
  pars <- ParsReplace(pars_optim, pars)
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------
  ptm <- proc.time()
  
  all.out <- foreach(i = data.samples$sample, .combine = 'rbind', 
                     .export = c("site.data.bf", "site.data.mz", "SampleCost",
                                 "pars", "data.samples", "input.all", "obs.accum", 
                                 "initial_state", "hour", "tstep"),
                     .packages = c("deSolve")) %dopar% {
    SampleRun(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
  }

  print(cat('t1', proc.time() - ptm))
  
  ### calculate accumulated fluxes as measured and pass to modCost function --------------
  C_R_mod <- AccumCalc(all.out, obs.accum)
  
  # Times from multiple samples are combined and may be repeated, so passing time to modCost to match
  # obs to mod may give wrong matches. Avoid this by creating new time with decimals determined by sample number:
  C_R_mod$time2 <- C_R_mod$time + C_R_mod$sample/100
  obs.accum$time2 <- obs.accum$hour + obs.accum$sample/100
  obs <- data.frame(name = rep("C_R", nrow(obs.accum)), time = obs.accum$time2, C_R = obs.accum$C_R, stderr = obs.accum$sd)
  mod <- data.frame(time = C_R_mod$time2, C_R = C_R_mod$C_R_m)
  
  print(cat('t2', proc.time() - ptm))
  
  if(cost.type == "uwr") {
    return(modCost(model=mod, obs=obs, y = "C_R"))
  } else if(cost.type == "wr") {
    return(modCost(model=mod, obs=obs, y = "C_R", error <- "stderr")) }
  
}

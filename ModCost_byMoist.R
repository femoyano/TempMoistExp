# ModCost.R
# This model calculates the model residuals
# This version calls SampleRun.R

ModCost <- function(pars_optim) {

  # t1 <- Sys.time()
  
  # Add or replace parameters from the list of optimized parameters ----------------------
  pars <- ParsReplace(pars_optim, pars_default)
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------

  mod.out <- foreach(i = data.samples$sample, .combine = 'rbind', 
                     .export = c(ls(envir = .GlobalEnv), "pars"),
                     .packages = c("deSolve")) %dopar% {
    SampleRun(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
  }
  
  # Get accumulated values to match observations and merge datasets
  data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"), by.y = c("sample", "time"))
  data.accum$C_R_mr <- data.accum$C_R_m / data.accum$time_accum * 1000  # observed data was also rescaled
  data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable
  
  it <- 1
  for (i in unique(data.accum$moist.group)) {
    df <- data.accum[data.accum$moist.group == i, ]
    obs <- data.frame(name = rep("C_R_r", nrow(df)), time = df$hour, C_R_r = df$C_R_r, sd.r = df$sd.r)
    mod <- data.frame(time = df$hour, C_R_r = df$C_R_mr)
    if(it == 1) {
      if(cost.type == "rate.sd") {
        cost <- modCost(model=mod, obs=obs, y = "C_R_r", err = "sd.r")
      } else if(cost.type == "rate.mean") {
        cost <- modCost(model=mod, obs=obs, y = "C_R_r", weight = "mean") 
      } else stop("Check cost.type option for using group rates: rate.mean or rate.sd")
    } else {
      if(cost.type == "rate.sd") {
        cost <- modCost(model=mod, obs=obs, y = "C_R_r", err = "sd.r", cost = cost)
      } else if(cost.type == "rate.mean") {
        cost <- modCost(model=mod, obs=obs, y = "C_R_r", weight = "mean", cost = cost) 
      } else stop("Check cost.type option for using group rates: rate.mean or rate.sd")
    }
    it = it + 1
  }

  cat(cost$model, cost$minlogp, "\n")
  
  # cat(Sys.time()-t1, " ")
  
  return(cost)
}

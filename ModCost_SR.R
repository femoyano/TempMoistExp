# ModCost.R
# This model calculates the model residuals
# This version calls SampleRun.R

ModCost <- function(pars_optim) {
  
  # t1 <- Sys.time()
  
  # Add or replace parameters from the list of optimized parameters ----------------------
  pars <- ParsReplace(pars_optim, pars_default)
  
  ### Run all treatments (in parallel if cores avaiable) ------------------------------------
  
  mod.out <- foreach(i = unique(input.all$treatment), .combine = 'rbind', 
                     .export = c(ls(envir = .GlobalEnv), "pars"),
                     .packages = c("deSolve")) %dopar% {
                       SampleRun(pars, input.all[input.all$treatment==i, ])
                     }
  
  # Get accumulated values to match observations and merge datasets
  data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("treatment", "hour"), by.y = c("treatment", "time"))
  data.accum$C_R_mr <- data.accum$C_R_m / data.accum$time_accum
  
  df <- data.accum
  obs <- data.frame(name = rep("C_R_r", nrow(df)), time = df$hour, C_R_r = df$C_R_r, sd = df$C_R_sd)
  mod <- data.frame(time = df$hour, C_R_r = df$C_R_mr)
  
  cost <- modCost(model=mod, obs=obs, y = "C_R_r", err = 'sd', weight = 'none') 
  
  cat(cost$model, cost$minlogp, "\n")
  
  # cat(Sys.time()-t1, " ")
  
  return(cost)
}

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
  # Make sure the model output was converted already to gC kg-1Soil!!!
  data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("treatment", "hour"), by.y = c("treatment", "time"))
  data.accum$C_R_rm <- data.accum$C_R_m / data.accum$time_accum # convert to hourly rates [gC kg-1 h-1]
  data.accum$C_R_ro <- data.accum$C_R_r  # Observed data should be already gC kg-1 h-1
  data.accum$C_R <- NULL
  # Convert to mg kg-1 h-1
  data.accum$C_R_ro <- data.accum$C_R_ro
  data.accum$C_R_rm <- data.accum$C_R_rm
  data.accum$C_R_sd <- data.accum$C_R_sd
  
  df <- data.accum
  obs <- data.frame(name = rep("C_R_r", nrow(df)), time = df$hour, C_R_r = df$C_R_ro, sd = df$C_R_sd, uw = 1)
  mod <- data.frame(time = df$hour, C_R_r = df$C_R_rm)
  
  cost <- modCost(model=mod, obs=obs, y = "C_R_r", err = SRerror, weight = SRweight) 
  
  cat(cost$model, cost$minlogp, "\n")
  
  # cat(Sys.time()-t1, " ")
  
  return(cost)
}

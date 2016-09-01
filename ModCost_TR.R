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
  
  data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable
  
  it <- 1
  for (i in unique(data.accum$moist.group)) {
    df <- data.accum[data.accum$moist.group == i, ]
    
    # Calculate T response
      SR5_o  <- mean(df$C_R_ro[df$temp==5])
    SR20_o <- mean(df$C_R_ro[df$temp==20])
    SR35_o <- mean(df$C_R_ro[df$temp==35])
    SR5_m  <- mean(df$C_R_mr[df$temp==5])
    SR20_m <- mean(df$C_R_mr[df$temp==20])
    SR35_m <- mean(df$C_R_mr[df$temp==35])
    TR5_20_o  <- SR20_o/SR5_o
    TR20_35_o <- SR35_o/SR20_o
    TR5_20_m  <- SR20_m/SR5_m
    TR20_35_m <- SR35_m/SR20_m
    
    obsTR <- data.frame(name = "TR", step = c(1,2), TR = c(TR5_20_o, TR20_35_o), error = 1)
    modTR <- data.frame(step = c(1,2), TR = c(TR5_20_m, TR20_35_m))
    
    if(it == 1) {
      cost <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", error = 'error',
                      weight = TRweight, scaleVar = TRUE)
    } else {
      cost <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", error = 'error',
                      weight = TRweight, scaleVar = TRUE, cost = cost)
    }
    it = it + 1
  }
  
  cat(cost$model, cost$minlogp, "\n")
  
  # cat(Sys.time()-t1, " ")
  
  return(cost)
}
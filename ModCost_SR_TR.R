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
  obsSR <- data.frame(name = rep("C_R_r", nrow(df)), time = df$hour, C_R_r = df$C_R_r, sd = df$C_R_sd)
  modSR <- data.frame(time = df$hour, C_R_r = df$C_R_mr)
    
  # Calculate T response
  SR5_o  <- mean(df$C_R_r[df$temp==5])
  SR20_o <- mean(df$C_R_r[df$temp==20])
  SR35_o <- mean(df$C_R_r[df$temp==35])
  SR5_m  <- mean(df$C_R_mr[df$temp==5])
  SR20_m <- mean(df$C_R_mr[df$temp==20])
  SR35_m <- mean(df$C_R_mr[df$temp==35])
  TR5_20_o  <- SR20_o/SR5_o
  TR20_35_o <- SR35_o/SR20_o
  TR5_20_m  <- SR20_m/SR5_m
  TR20_35_m <- SR35_m/SR20_m
  
  obsTR <- data.frame(name = rep("TR", 2), step = c(1,2), TR = c(TR5_20_o, TR20_35_o))
  modTR <- data.frame(step = c(1,2), TR = c(TR5_20_m, TR20_35_m))
  
  cost <- modCost(model=modSR, obs=obsSR, y = "C_R_r", err = sd, 
                  weight = 'none', scaleVar = scalevar)
  cost <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", err = NULL,
                  weight = 'none', cost = cost, scaleVar = scalevar)

  cat(cost$model, cost$minlogp, "\n")
  
  # cat(Sys.time()-t1, " ")
  
  return(cost)
}

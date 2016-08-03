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
  data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"),
                      by.y = c("sample", "time"))
  data.accum$C_R_mr <- data.accum$C_R_m / data.accum$time_accum * 1000         # observed data was also rescaled
  data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable
  
  it <- 1
  for (i in unique(data.accum$moist.group)) {
    df <- data.accum[data.accum$moist.group == i, ]
    obsSR <- data.frame(name = rep("C_R_r", nrow(df)), time = df$hour,
                        C_R_r = df$C_R_r, sd.r = df$sd.r)
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
    
    obsTR <- data.frame(name = "TR", step = c(1,2), TR = c(TR5_20_o, TR20_35_o))
    modTR <- data.frame(step = c(1,2), TR = c(TR5_20_m, TR20_35_m))
    
    if(it == 1) {
      cost <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", error = TRerror,
                      weight = TRweight, scaleVar = TRUE)
    } else {
      cost <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", error = TRerror,
                      weight = TRweight, scaleVar = TRUE, cost = cost)
    }
    it = it + 1
  }

  cat(cost$model, cost$minlogp, "\n")
  
  # cat(Sys.time()-t1, " ")
  
  return(cost)
}

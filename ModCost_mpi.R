# ModCost.R
# This model calculates the model residuals

ModCost <- function(pars, pars_calib) {

  # Add or replace parameters from the list of optimized parameters ----------------------
  pars <- ParsReplace(pars_calib, pars)
  
  ### Run all samples (in series since this is for mpi) ------------------------------------

  mod.out <- foreach(i = data.samples$sample, .combine = 'rbind') %do% {
    SampleRun(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
  }
  
  # Get accumulated values to match observations and merge datasets
  data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"), by.y = c("sample", "time"))
  data.accum$C_R_mr <- data.accum$C_R_m / data.accum$time_accum * 1000  # observed data was also rescaled
  data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable
  
  it <- 1
  for (i in unique(data.accum$moist.group)) {
    df <- data.accum[data.accum$moist.group == i, ]
    obsSR <- data.frame(name = rep("C_R_r", nrow(df)), time = df$hour, C_R_r = df$C_R_r, sd.r = df$sd.r)
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
    
    if(it == 1) {
      cost.sr.sd <- modCost(model=modSR, obs=obsSR, y = "C_R_r", err = "sd.r")
      cost.tr.sd <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", weight = 'std')
      cost.sr.m  <- modCost(model=modSR, obs=obsSR, y = "C_R_r", weight = "mean")
      cost.tr.m  <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", weight = "mean")
      cost.sr.uw <- modCost(model=modSR, obs=obsSR, y = "C_R_r")
      cost.tr.uw <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR")
    } else {
      cost.sr.sd <- modCost(model=modSR, obs=obsSR, y = "C_R_r", err = "sd.r", cost = cost.sr.sd)
      cost.tr.sd <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", weight = 'std', cost = cost.tr.sd)
      cost.sr.m  <- modCost(model=modSR, obs=obsSR, y = "C_R_r", weight = "mean", cost = cost.sr.m)
      cost.tr.m  <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", weight = "mean", cost = cost.tr.m)
      cost.sr.uw <- modCost(model=modSR, obs=obsSR, y = "C_R_r", cost = cost.sr.uw)
      cost.tr.uw <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", cost = cost.tr.uw)
    }
    it = it + 1
  }

  out <- c(modcost.sr.sd = cost.sr.sd$model,
           modcost.tr.sd = cost.tr.sd$model, 
           modcost.sr.m  = cost.sr.m$model, 
           modcost.tr.m  = cost.tr.m$model, 
           modcost.sr.uw = cost.sr.uw$model, 
           modcost.tr.uw = cost.tr.uw$model,
           minlogp.sr.sd = cost.sr.sd$minlogp,
           minlogp.tr.sd = cost.tr.sd$minlogp, 
           minlogp.sr.m  = cost.sr.m$minlogp, 
           minlogp.tr.m  = cost.tr.m$minlogp, 
           minlogp.sr.uw = cost.sr.uw$minlogp, 
           minlogp.tr.uw = cost.tr.uw$minlogp
  )
  
  return(out)
}

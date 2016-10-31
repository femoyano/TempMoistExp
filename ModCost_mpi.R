# ModCost.R
# This model calculates the model residuals

ModCost <- function(pars) {
  
  mod.out <- foreach(i = unique(input.all$treatment), .combine = 'rbind') %do% {
    SampleRun(pars, input.all[input.all$treatment==i, ])
  }
  
  # Get accumulated values to match observations and merge datasets
  # Make sure the model output was converted already to gC kg-1Soil!!!
  data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("treatment", "hour"), by.y = c("treatment", "time"))
  data.accum$C_R_rm <- data.accum$C_R_m / data.accum$time_accum # convert to hourly rates [gC kg-1 h-1]
  data.accum$C_R_ro <- data.accum$C_R_r  # Observed data should be already gC kg-1 h-1
  data.accum$C_R <- NULL
  
  # # Convert to mg kg-1 h-1    ------- ???????? what's this? already ok units?
  # data.accum$C_R_ro <- data.accum$C_R_ro
  # data.accum$C_R_rm <- data.accum$C_R_rm
  # data.accum$C_R_sd <- data.accum$C_R_sd
  
  df <- data.accum
  obsSR <- data.frame(name = "C_R_r", time = df$hour, C_R_r = df$C_R_ro, error = df[,SRerror])
  modSR <- data.frame(time = df$hour, C_R_r = df$C_R_rm)
  
  # Calculate T response
  SR5_o  <- mean(df$C_R_r[df$temp==5])
  SR20_o <- mean(df$C_R_r[df$temp==20])
  SR35_o <- mean(df$C_R_r[df$temp==35])
  SR5_m  <- mean(df$C_R_rm[df$temp==5])
  SR20_m <- mean(df$C_R_rm[df$temp==20])
  SR35_m <- mean(df$C_R_rm[df$temp==35])
  TR5_20_o  <- SR20_o/SR5_o
  TR20_35_o <- SR35_o/SR20_o
  TR5_20_m  <- SR20_m/SR5_m
  TR20_35_m <- SR35_m/SR20_m
  
  obsTR <- data.frame(name = "TR", step = c(1,2), TR = c(TR5_20_o, TR20_35_o))
  modTR <- data.frame(step = c(1,2), TR = c(TR5_20_m, TR20_35_m))
  
  cost.sr <- modCost(model=modSR, obs=obsSR, y = "C_R_r", err = 'error', weight = SRweight)
  cost.tr <- modCost(model=modTR, obs=obsTR, x = "step", y = "TR", err = NULL, weight = TRweight)

  out <- c(modcost.sr = cost.sr$model,
           modcost.tr = cost.tr$model, 
           minlogp.sr = cost.sr$minlogp,
           minlogp.tr = cost.tr$minlogp
  )
  
  return(out)
}

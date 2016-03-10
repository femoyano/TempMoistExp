# ModCost.R
# This model calculates the model residuals
# This version calls SampleRun.R

ModCost <- function(pars_optim) {
  
  # Source the model preparing each sample for model run.
  source("SampleRun.R")

  # Add or replace parameters from the list of optimized parameters ----------------------
  for(n in names(pars_optim)) pars[[n]] <- pars_optim[[n]]
  # Replace param values where assignment is required
  pars[["E_r_ed"]] <- pars[["E_r_md"]] <- pars[["E_VD"]] <- pars[["E_V"]]
  pars[["E_KD"]] <- pars[["E_K"]]
  if("E_k" %in% names(pars_optim)) pars[["E_ka"]] <- pars[["E_kd"]] <- pars[["E_k"]]
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------
  ptm <- proc.time()
  
  all.out <- foreach(i = data.samples$sample, .combine = 'rbind', 
                     .export = c("runSamples", "pars", "data.samples", "input.all"),
                     .packages = c("deSolve")) %dopar% {
    SampleRun(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
  }

  print(cat('t1', proc.time() - ptm))
  
  colnames(all.out) <- c("time", "C_P", "C_D", "C_A", "C_Ew", "C_Em", "C_M", "C_R", "sample")
  
  ### calculate accumulated fluxes as measured and pass to modCost function --------------
 
  # Parallel --------------------------------
  
  ptm <- proc.time()
  
  accumFun <- function(j, all.out) {
    C_R_m <- NA
    snum <- seq((j-1)*x+1,j*x)
    if (j == cores) snum <- seq((j-1)*x+1, nrow(data.meas))
    it <- 1
    for (i in snum) {
      t1 <- data.meas$hour[i]
      t0 <- t1 - data.meas$time_inc[i]
      s  <- data.meas$sample[i]
      C_R_m[it] <- all.out[all.out[,'sample'] == s & all.out[,'time'] == t1, 'C_R'] - all.out[all.out[,'sample'] == s & all.out[,'time'] == t0, 'C_R'] 
      it <- it+1
    }
    return(data.frame(C_R_m = C_R_m))
  }

  x <- floor(nrow(data.meas) / cores)
  
  ## Process in parallel
  C_R_mod <- foreach (j=1:cores, .combine = 'rbind', .export = c("data.meas")) %dopar% {
    accumFun(j, all.out)
  }
  
  # Times from multiple samples are combined and may be repeated, so passing time to modCost to match
  # obs to mod may give wrong matches. Creating new time with decimals determined by sample number:
  time <- data.meas$time + data.meas$sample/100
  obs <- data.frame(name = rep("C_R", nrow(data.meas)), time = time, C_R = data.meas$C_R, stderr = data.meas$sd)
  mod <- data.frame(time = time, C_R = C_R_mod$C_R_m)
  
  print(cat('t2', proc.time() - ptm))
  
  return(modCost(model=mod, obs=obs, y = "C_R", err = "stderr"))
  
}

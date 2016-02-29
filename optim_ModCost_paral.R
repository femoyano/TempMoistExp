# Define model run function here
ModCost <- function(pars_optim) {
  
  # Source the model preparing each sample for model run.
  source("optim_runSamples_paral.R")

  # Add or replace parameters from the list of optimized parameters ----------------------
  for(n in names(pars_optim)) pars[[n]] <- pars_optim[[n]]
  # Replace param values where assignment is required
  pars[["E_r_ed"]] <- pars[["E_r_md"]] <- pars[["E_VD"]] <- pars[["E_V"]]
  pars[["E_KD"]] <- pars[["E_K"]]
  if("E_k" %in% names(pars_optim)) pars[["E_ka"]] <- pars[["E_kd"]] <- pars[["E_k"]]
  
  ### Run all samples (in parallel if cores avaiable) ------------------------------------
  ptm <- proc.time()
  all.out <- foreach(i = data.samples$sample, .combine = 'rbind') %dopar% {
    runSamples(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
  }
  print(cat('t1', proc.time() - ptm))
  
  colnames(all.out) <- c("time", "C_P", "C_D", "C_A", "C_Ew", "C_Em", "C_M", "C_R", "sample")
  
  ### calculate accumulated fluxes as measured and pass to modCost function --------------
 
  # Parallel --------------------------------
  
  ptm <- proc.time()
  
  accumFun <- function(j, all.out) {
    C_R_m <- NA
    C_R_o <- NA
    time <- NA
    snum <- seq((j-1)*x+1,j*x)
    if (j == cores) snum <- seq((j-1)*x+1, nrow(data.meas))
    it <- 1
    for (i in snum) {
      t1 <- data.meas$hour[i]
      t0 <- t1 - data.meas$time_inc[i]
      s  <- data.meas$sample[i]
      C_R_m[it] <- all.out[all.out[,'sample'] == s & all.out[,'time'] == t1, 'C_R'] - all.out[all.out[,'sample'] == s & all.out[,'time'] == t0, 'C_R'] 
      C_R_o[it] <- data.meas$C_R[i]
      time[it] <- data.meas$hour[i]
      it <- it+1
    }
    return(cbind(C_R_m, C_R_o, time))
  }

  cores <- getDoParWorkers()
  x <- floor(nrow(data.meas) / cores)
  
  out <- foreach (j=1:cores, combine = 'rbind') %dopar% {
    accumFun(j, all.out)
  }

  out <- as.data.frame(out)

  obs <- subset(out, select = c("time", "C_R_o"))
  mod <- subset(out, select = c("time", "C_R_m"))
  mod$C_R <- mod$C_R_m
  mod$C_R_m <- NULL
  obs$C_R <- obs$C_R_o
  obs$C_R_o <- NULL
  
  print(cat('t2', proc.time() - ptm))
  
  return(modCost(model=mod, obs=obs, x="time"))
  
}

AccumCalc <- function(all.out, obs.accum) {
  
  accumFun <- function(j) {
    C_R_m <- NA
    sample <- NA
    time <- NA
    snum <- seq((j-1)*x+1,j*x)
    if (j == cores) snum <- seq((j-1)*x+1, nrow(obs.accum))
    it <- 1
    for (i in snum) {
      t1 <- obs.accum$hour[i]
      t0 <- t1 - obs.accum$time_inc[i]
      s  <- obs.accum$sample[i]
      C_R_m[it] <- all.out[all.out[,'sample'] == s & all.out[,'time'] == t1, 'C_R'] - all.out[all.out[,'sample'] == s & all.out[,'time'] == t0, 'C_R'] 
      sample[it] <- s
      time[it] <- t1
      it <- it+1
    }
    return(data.frame(C_R_m = C_R_m, sample = sample, time = time))
  }
  
  if(!exists("cores")) cores <- 1
  x <- floor(nrow(obs.accum) / cores)
  
  ## Process in parallel
  C_R_mod <- foreach (j=1:cores, .combine = 'rbind', 
                      .export = c("obs.accum", "x", "cores", "all.out")
                      ) %dopar% {
    accumFun(j)
  }
  
  return(C_R_mod)
}

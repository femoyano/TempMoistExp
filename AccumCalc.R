
AccumCalc <- function(all.out) {
  accumFun <- function(j, all.out) {
    C_R_m <- NA
    sample <- NA
    time <- NA
    snum <- seq((j-1)*x+1,j*x)
    if (j == cores) snum <- seq((j-1)*x+1, nrow(data.accum))
    it <- 1
    for (i in snum) {
      t1 <- data.accum$hour[i]
      t0 <- t1 - data.accum$time_inc[i]
      s  <- data.accum$sample[i]
      C_R_m[it] <- all.out[all.out[,'sample'] == s & all.out[,'time'] == t1, 'C_R'] - all.out[all.out[,'sample'] == s & all.out[,'time'] == t0, 'C_R'] 
      sample[it] <- s
      time[it] <- t1
      it <- it+1
    }
    return(data.frame(C_R_m = C_R_m, sample = sample, time = time))
  }
  
  cores <- detectCores()
  x <- floor(nrow(data.accum) / cores)
  
  ## Process in parallel
  C_R_mod <- foreach (j=1:cores, .combine = 'rbind', .export = c("data.accum")) %dopar% {
    accumFun(j, all.out)
  }
  
  return(C_R_mod)
}

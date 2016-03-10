
AccumCalc <- function(all.out) {
  
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
  
  return(C_R_mod)
}

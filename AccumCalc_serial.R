AccumCalc <- function(all.out, obs.accum) {
C_R_m <- NA
sample <- NA
time <- NA
for (i in 1:nrow(obs.accum)) {
  t1 <- obs.accum$hour[i]
  t0 <- t1 - obs.accum$time_accum[i]
  s  <- obs.accum$sample[i]
  C_R_m[i] <- all.out[all.out[,'sample'] == s & all.out[,'time'] == t1, 'C_R'] - all.out[all.out[,'sample'] == s & all.out[,'time'] == t0, 'C_R'] 
  sample[i] <- s
  time[i] <- t1
  }
return(data.frame(C_R_m = C_R_m, sample = sample, time = time))
}

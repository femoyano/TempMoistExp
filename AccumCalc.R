AccumCalc <- function(all.out, obs.accum) {
C_R_m <- NA  # Carbon respired [g kg-1]
treatment <- NA
time <- NA
for (i in 1:nrow(obs.accum)) {
  t1 <- obs.accum$hour[i]
  t0 <- t1 - obs.accum$time_accum[i]
  t  <- obs.accum$treatment[i]
  C_R_m[i] <- all.out[all.out[,'treatment'] == t & all.out[,'time'] == t1, 'C_R'] - 
    all.out[all.out[,'treatment'] == t & all.out[,'time'] == t0, 'C_R'] 
  treatment[i] <- t
  time[i] <- t1
  }
return(data.frame(C_R_m = C_R_m, treatment = treatment, time = time))
}

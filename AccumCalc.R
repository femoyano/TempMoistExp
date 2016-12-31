AccumCalc <- function(mod.out, obs.accum) {
  C_R_m <- NA  # Carbon respired [g kg-1]
  C_dec <- NA # Carbon decomposed [g kg-1]
  treatment <- NA
  time <- NA

  for (i in 1:nrow(obs.accum)) {
    t1 <- obs.accum$hour[i]
    t0 <- t1 - obs.accum$time_accum[i]
    t  <- obs.accum$treatment[i]
    C_R_m[i] <- mod.out[mod.out[,'treatment'] == t & mod.out[,'time'] == t1, 'C_R'] -
      mod.out[mod.out[,'treatment'] == t & mod.out[,'time'] == t0, 'C_R']
    C_dec[i] <- mod.out[mod.out[,'treatment'] == t & mod.out[,'time'] == t1, 'C_dec'] -
      mod.out[mod.out[,'treatment'] == t & mod.out[,'time'] == t0, 'C_dec']
    treatment[i] <- t
    time[i] <- t1
  }
  return(data.frame(C_R_m = C_R_m, C_dec = C_dec, treatment = treatment, time = time))
}

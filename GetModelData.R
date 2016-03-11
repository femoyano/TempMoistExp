# GetModelData.R
# script to add model to observed data

GetModelData <- function(data.accum, input.all, Modfit) {
  source("ParsReplace.R")
  source("SampleRun.R")
  source("AccumCalc.R")
  pars_calib <- Modfit$par
  pars <- ParsReplace(pars_calib, pars)
  all.out <- foreach(i = data.samples$sample, .combine = 'rbind', 
                     .export = c("runSamples", "pars", "data.samples", "input.all"),
                     .packages = c("deSolve")) %dopar% {
                     SampleRun(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
                     }
  data.mod <- AccumCalc(all.out)
  data.mod <- data.mod[order(data.mod$sample, data.mod$time),]
  data.accum$C_R_m <- data.mod$C_R_m
  return(list(all.out, data.accum))
}

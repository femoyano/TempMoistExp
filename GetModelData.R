# GetModelData.R
# script to add model to observed data

GetModelData <- function(input.all, pars_modfit) {
  source("ParsReplace.R")
  source("SampleRun.R")
  source("AccumCalc.R")
  pars <- ParsReplace(pars_modfit, pars)
  all.out <- foreach(i = data.samples$sample, .combine = 'rbind', 
                     .export = c("runSamples", "pars", "data.samples", "input.all"),
                     .packages = c("deSolve")) %dopar% {
                     SampleRun(pars, data.samples[data.samples$sample==i, ], input.all[input.all$sample==i, ])
                     }
  return(all.out)
}

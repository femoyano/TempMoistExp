# GetModelData.R
# script to add model to observed data

GetModelData <- function(pars) {
  
  source("SampleRun.R")

  all.out <- foreach(i = data.samples$sample, .combine = 'rbind',
                     .export = c(ls(envir = .GlobalEnv), "pars"),
                     .packages = c("deSolve")) %dopar% {
                       SampleRun(pars, data.samples[data.samples$sample==i, ],
                                 input.all[input.all$sample==i, ])
                     }
  return(all.out)
}

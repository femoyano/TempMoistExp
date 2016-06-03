# script to make a simple run of Nadia's incubation data

SampleRunSimple <- function(pars_optim) {
  
  source("ParsReplace.R")
  source("SampleRun.R")
  pars <- ParsReplace(pars_optim, pars)
  
  all.out <- list()
  
  for(i in 1:nrow(data.samples)) {
    all.out[[i]] <- SampleRun(pars, data.samples[i, ], input.all[input.all$sample == data.samples$sample[i], ])
  }
  
  return(all.out)
}

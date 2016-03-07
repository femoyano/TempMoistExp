# For SMP jobs

library(doParallel)
corenum <- detectCores()
cat("detectCores output:", corenum, "\n")
registerDoParallel(cores=corenum)
cat("getDoParWorkers output:", getDoParWorkers(), "\n")


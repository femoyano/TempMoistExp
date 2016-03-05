# For SMP jobs

library(doParallel)
corenum <- detectCores()
cat("cat detectCores ", corenum)
print("print detectCores ", corenum)
registerDoParallel(cores=corenum)
print(getDoParWorkers())



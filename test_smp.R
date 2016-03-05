# For SMP jobs

library(doParallel)
corenum <- detectCores()
registerDoParallel(cores=corenum)
cat("cat detectCores ", detectCores())
print("print detectCores ", detectCores())
print(getDoParWorkers())



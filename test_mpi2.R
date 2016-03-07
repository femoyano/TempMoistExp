# For MPI jobs

library(doParallel)
cl <- makeCluster() # is this OK? Dcos say parallel socket cluster
cat("clusterSize output:", clusterSize(cl), "\n")
cat("detectCores:", detectCores())
registerDoParallel(cl)
cat("getDoParWorkers output:", getDoParWorkers())
stopCluster(cl)

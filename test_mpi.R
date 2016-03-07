# For MPI jobs

library(doMPI)
cl <- startMPIcluster()
cat("clusterSize output:", clusterSize(cl), "\n")
registerDoMPI(cl)
cat("gitDoParWorkers output:", getDoParWorkers())
closeCluster(cl)
mpi.quit()
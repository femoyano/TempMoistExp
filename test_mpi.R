# For MPI jobs

library(foreach)
library(doMPI)
cl <- startMPIcluster()
cat("Step 1 \n")
cat("cat clusterSize function here: ", clusterSize(cl))
print("print clusterSize function here: ", clusterSize(cl))
cat("cat detectCores ", detectCores())
print("print detectCores ", detectCores())
registerDoMPI(cl)
print("Workers ", getDoParWorkers())
closeCluster(cl)
mpi.quit()




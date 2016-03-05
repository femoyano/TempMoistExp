# Run only one chunk. Comment out the rest

# # For MPI jobs
library(foreach)
library(doParallel)
cl <- startMPIcluster()
registerDoMPI(cl)
cat("Step 1 \n")
cat("cat clusterSize function here: ", clusterSize(cl))
print("print clusterSize function here: ", clusterSize(cl))
cat("cat detectCores ", detectCores())
print("print detectCores ", detectCores())
closeCluster(cl)
mpi.quit()


# For SMP jobs
# library(doParallel)
# corenum <- detectCores()
# registerDoParallel(cores=corenum)
# cat("cat detectCores ", detectCores())
# print("print detectCores ", detectCores())
# print(getDoParWorkers())



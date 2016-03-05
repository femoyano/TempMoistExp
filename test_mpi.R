# For MPI jobs

library(foreach)
library(doParallel)
cl <- makeCluster()
cat("Step 1 \n")
cat("cat clusterSize function here: ", clusterSize(cl))
print("print clusterSize function here: ", clusterSize(cl))
cat("cat detectCores ", detectCores())
print("print detectCores ", detectCores())
registerDoParallel(cl)
closeCluster(cl)
mpi.quit()




#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as distributed memory job (MPI)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### Setings for parallel processing
library(doMPI)
cl <- startMPIcluster()
registerDoMPI(cl)
cores <- clusterSize(cl)

source("optim_run_main.R")

closeCluster(cl)
mpi.quit()

#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

source('MainMpi.R')
source('setup.R')
list2env(setup, envir = .GlobalEnv)
pars_mpi <- as.matrix(read.csv(pars.mpi.file))

### ----------------------------------- ###
###    Run parallel processing  ###
### ----------------------------------- ###

library(doMPI)
cl <- startMPIcluster()
registerDoMPI(cl)
cores <- clusterSize(cl)

runs.out <- foreach(pars_replace = iter(pars_mpi, by='row'),
                    .combine = 'rbind', 
                    .errorhandling = 'remove',
                    .packages = c('deSolve', 'FME', 'plyr', 'reshape2', 'foreach')
                    ) %dopar% {
                      MainMpi(pars_replace)
                      }

savetime  <- format(Sys.time(), "%m%d-%H%M")
save.image(file = paste("Run_MPI_", savetime, savetxt, ".RData", sep = ""))

closeCluster(cl)
mpi.quit()

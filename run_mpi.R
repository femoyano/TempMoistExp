#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### ----------------------------------- ###
###        Setting parameters        ###
### ----------------------------------- ###

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose default parameters
pars.default.file <-'parsets/parset6-6noAC_all.csv'
pars <- read.csv(pars.default.file, row.names = 1)
pars <- setNames(pars[[1]], row.names(pars))

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose initial valeus for optimized parameters
pars.calib.file   <- '../parsets/pars_lh50000_bounds1_v1.csv'
pars_calib <- as.matrix(read.csv(pars.calib.file))

source('MainMpi.R')


### ----------------------------------- ###
###    Run parallel processing  ###
### ----------------------------------- ###

library(doMPI)
cl <- startMPIcluster()
registerDoMPI(cl)
cores <- clusterSize(cl)
runs.out <- foreach(i = 1:nrow(pars_calib),
                    .combine = 'rbind', 
                    .errorhandling = 'remove', 
                    .packages = c('deSolve', 'FME', 'plyr', 'reshape2')
                    ) %dopar% {
                      pars_replace <- pars_calib[i,]
                      MainMpi(pars, pars_replace)
                      }

save(runs.out, file = 'runs.out.Rdata')

closeCluster(cl)
mpi.quit()

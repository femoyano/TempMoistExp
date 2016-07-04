#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### ----------------------------------- ###
###        Setting up parameters        ###
### ----------------------------------- ###

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose default parameters
pars.default.file <- 'parset6.csv'
pars <- as.matrix(read.csv(pars.default.file))[1,]

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Choose initial valeus for optimized parameters
pars.calib.file   <- 'pars_lh100_bounds1_v1.csv'
pars_calib <- as.matrix(read.csv(file=pars.calib.file))

source('main_mpi.R')


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
                      RunMain(pars, pars_calib[i,])
                      }
# Save the output
cat('Printing out some of the results: \n')
print(head(runs.out))

cat('Now will save the data to file.')
save(runs.out, file = 'runs.out.Rdata')

closeCluster(cl)
mpi.quit()

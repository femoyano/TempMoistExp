#### optim_run_smp.R

#### Documentations ===========================================================
# Script used to run optimization as shared memory job (SMP)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

### Setings for parallel processing
library(doParallel)
cores = detectCores()
cat("Cores detected:", cores, "\n")
registerDoParallel(cores = cores)

source("optim_run_main.R")

save.image("optimsmp.RData")

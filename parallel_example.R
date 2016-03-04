# Run only one chunk. Comment out the rest

# # For MPI jobs
# library(foreach)
# library(doMPI)
# cl <- startMPIcluster()
# registerDoMPI(cl)
# cat("Step 1")
# cat(clusterSize(cl))
# closeCluster(cl)
# mpi.quit()


# For SMP jobs
library(randomForest)
library(doParallel)
corenum <- detectCores()
registerDoParallel(cores=corenum)
print(cornum)


# x <- iris[which(iris[,5] != "setosa"), c(1,5)]
# trials <- 10000
# ptime <- system.time({
#   r <- foreach(icount(trials), .combine=cbind) %dopar% {
#     ind <- sample(100, 100, replace=TRUE)
#     result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
#     coefficients(result1)
#   }
# })[3]
# ptime

# Model = foreach(i=1:clusterSize(cl),.options.mpi = list(seed=1337) ) %dopar% {
#   
#   cat("Step 2")
#   library(MCMCglmm)
#   load("mydata.rdata")
#   nitt = 7000; thin = 50; burnin = 3000
#   MCMCglmm( outcome ~ pred ,
#             random=~idParents,
#             family="poisson", 
#             data=mydata, 
#             pr = F, saveX = T, saveZ = T,
#             nitt=nitt,thin=thin,burnin=burnin)
# }
# library(coda)
# mcmclist = mcmc.list(lapply(Model,FUN=function(x) { x$Sol}))
# save(Model,mcmclist, file = "Model.rdata")

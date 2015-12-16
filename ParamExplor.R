
## Code for first exploration of parameter values -----
var1svec   <- seq(1,1.5,by=.05)
nvar1vec <- length(var1svec)
var2vec    <- seq(0.001,0.05,by=0.002)
nvar2vec <- length(var2vec)
# etc. more parameters can be added (adjusting loops below)
outcost <- matrix(nrow=nvar1vec,ncol=nvar2vec)
for (m in 1:nvar1vec)
{
  for (i in 1:nvar2vec)
  {
    pars <- c(k=nvar2vec[i],mult=var1svec[m])
    outcost[m,i] <- costf(pars)
  }
}
minpos<-which(outcost==min(outcost),arr.ind=TRUE)
var1m<-var1svec[minpos[1]]
var2i<-nvar2vec[minpos[2]]

## Calling the optimization function
optpar <- pricefit(par=c(var1=var1m,var2=var2i), minpar=c(0.001,1),
                   maxpar=c(0.05,1.5),func=Costfun, npop=50, numiter=500,
                   centroid=3, varleft=1e-8)

#### Documentation ============================================================
# This optimization script is the Controlled Random Search from Price 1977
# Code adapted from A Practical Guide to Ecological Modelling (Soetaert and Herman)
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================


Pricefit <- function (
    par,                             # initial par estimates
    minpar=rep(-1e8,length(par)),    # minimal parameter values
    maxpar=rep(1e8,length(par)),     # maximal parameter values
    func,                            # function to minimise
    npop=max(5*length(par),50),      # nr elements in population
    numiter=10000,                   # number of iterations
    centroid = 3,                    # number of points in centroid
    varleft = 1e-8,                  # relative variation upon stopping
    ...)
  
  {
  
  # Initialization
  
  cost <- function (par) func(par,...)
  npar <- length(par)
  tiny <- 1e-8
  varleft<-max(tiny,varleft)
  
  populationpar           <- matrix(nrow=npop, ncol=npar, byrow=TRUE,
                             data= minpar+runif(npar*npop)*rep((maxpar-minpar), npop))
  colnames(populationpar) <- names(par)
  populationpar[1,]       <- par
  
  populationcost <- apply(populationpar, FUN=cost, MARGIN=1)
  iworst         <- which.max(populationcost)
  worstcost      <- populationcost[iworst]
  
  # Hybridization phase
  iter<-0
  while (iter<numiter & (max(populationcost)-min(populationcost))
         >(min(populationcost)*varleft))
  {
    iter<-iter+1
    
    selectpar <- sample(1:npop, size=centroid)        # for cross-fertilization
    mirrorpar <- sample(1:npop, size=1)               # for mirroring
    newpar    <- colMeans(populationpar[selectpar,])  # centroid
    newpar    <- 2*newpar - populationpar[mirrorpar,] # mirroring
    
    newpar    <- pmin( pmax(newpar,minpar), maxpar)
    
    newcost <- cost(newpar)
    
    if (newcost < worstcost)
    {
      populationcost[iworst] <- newcost
      populationpar [iworst,] <- newpar
      iworst    <- which.max(populationcost) # new worst member
      worstcost <- populationcost[iworst]
    }
  } # end j loop
  
  ibest    <- which.min(populationcost)
  bestpar  <- populationpar[ibest,]
  bestcost <- populationcost[ibest]
  return (list(par = bestpar, cost = bestcost,
               poppar = populationpar, popcost=populationcost))
}

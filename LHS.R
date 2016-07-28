#latin Hypercube matrix generators (THANKS TO KARIN STEFFENS!!!)

source("../parsets/pars_bounds_v1.R")

################################################################
################################################################

num <- 10000 # number of simulations starts

require(lhs)
### latin hypercube sampling from uniform distribution [0,1] 
LH <- randomLHS(num, ncol(pars_bounds))

### attributes the correct parameter value to the particular sampled value - uniform distribution
pars.calib <- LH
for (i in 1:ncol(pars_bounds)) {
  pars.calib[,i] <- qunif(pars.calib[,i],
                  pars_bounds[1,i], 
                  pars_bounds[2,i]
  )  
}
colnames(pars.calib) <- colnames(pars_bounds)

################################################################
################################################################

#Write the parameter matrix and the pars min-max in a file
write.csv (pars.calib, file="pars_lh10000_bounds1_v3.csv", quote=FALSE, row.names = FALSE)

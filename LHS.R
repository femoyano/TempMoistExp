#latin Hypercube matrix generators (THANKS TO KARIN STEFFENS!!!)

pars.bounds.file <- "./parsets/pars_bounds_v1.csv"
pars_bounds <- read.csv(pars.bounds.file, row.names = 1)

################################################################
################################################################

num <- 100 # number of simulations starts

require(lhs)
### latin hypercube sampling from uniform distribution [0,1] 
LH <- randomLHS(num, nrow(pars_bounds))

### attributes the correct parameter value to the particular sampled value - uniform distribution
pars.calib <- LH
for (i in 1:nrow(pars_bounds)) {
  pars.calib[,i] <- qunif(pars.calib[,i],
                  pars_bounds[i,1], 
                  pars_bounds[i,2]
  )  
}
colnames(pars.calib) <- rownames(pars_bounds)

################################################################
################################################################

#Write the parameter matrix and the pars min-max in a file
write.csv (pars.calib, file="pars_lh100_bounds1_v1.csv", quote=FALSE, row.names = FALSE)

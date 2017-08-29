### ===================================== ###
### Plots of model results                ###
### ===================================== ###


### Libraries
require(plyr)
require(reshape2)
library(ggplot2)

prefix <- "plot_"
savedir <- file.path("plots")
devname <- "png"
devfun <- png
export <- 0
opar <- par(no.readonly=TRUE)

# # Plot residuals ----------------------------------------------------------------
# palette("default")
# plot(res, col = data.accum$temp, main = "By Temperature")
# plot(res, col = as.factor(data.accum$moist_vol), main = "By Moisture")
# plot(res, col = data.accum$site, main = "By Site")

# Plot accumulated model vs data --------------------------------------------------
plotname <- paste(prefix, "accum_mod_obs.", devname, sep = "")
plotfile <- file.path(savedir, plotname)
if(export) devfun(file = plotfile) #, width = 5, height = 5)
plot(data.accum$C_R_ro, data.accum$C_R_rm, col = data.accum$site,
     xlab = "Observed Accumulated CO2 (gC)", ylab = "Modeled Accumulated CO2 (gC)")
lines(c(0,1),c(0,1))

if(exists('mcmcMod')) {
  library(RColorBrewer)
  col_palette<-c(brewer.pal(7,"Set1"), brewer.pal(7,"Set2"), brewer.pal(7,"Set3"))
  densities<-list()
  for(i in 1:dim(mcmcMod$pars)[2]){
    densities[[i]]<-density(mcmcMod$pars[,i])
  }
  plotname <- paste(prefix, "pars_probdens.", devname, sep = "")
  plotfile <- file.path(savedir, plotname)
  if(export) devfun(file = plotfile, width = 1700, height = 800)
  par(mfrow=c(3,7), pin = c(1.3, 1.3), mar = c(5,4,3.5,3))
  for(i in 1:dim(mcmcMod$pars)[2]){
    plot(densities[[i]], main=colnames(mcmcMod$pars)[i])
    polygon(densities[[i]], col=col_palette[i])
  }
}
par(opar)

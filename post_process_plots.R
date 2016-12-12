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
export <- 1
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


# # Plot rates model vs data -----------------------------------------------------
# plotname <- paste(prefix, "rates_mod_obs.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# plot(data.accum$C_R_ro, data.accum$C_R_rm, col = data.accum$site, 
#      xlab = "Observed Respired CO2 (mgC h-1 m-3)", ylab = "Modeled Respired CO2 (mgC h-1 m-3)")
# lines(c(0,1),c(0,1))

# # Plot rates model vs data adding non-calibrated values ------------------------
# calib.accum.obs.r <- data.accum$C_R_ro
# calib.accum.mod.r <- data.accum$C_R_rm
# # Run with init pars here!!!
# palette("default")
# # Plot rates model vs data
# plotname <- paste(prefix, "rates_mod_obs.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# plot(data.accum$C_R_ro, data.accum$C_R_rm, col = "gray",
#      xlab = "Observed Respired CO2 (mgC h-1 m-3)", ylab = "Modeled Respired CO2 (mgC h-1 m-3)")
# points(calib.accum.obs.r, calib.accum.mod.r, col = "green")
# lines(c(0,1),c(0,1))


cv <- rainbow(10, alpha = 0.5)  # heat.colors(10, alpha = 0.5)
palette(cv)

# # Plot normalized values for each temp group -------------------------------------
# x <- data.frame(moist_vol = seq(0.01, 0.5, 0.001))
# for (i in names(fit.moist.obs)) {
#   y.o <- predict(fit.moist.obs[[i]]$fit, newdata = x)
#   y.m <- predict(fit.moist.mod[[i]]$fit, newdata = x)
#   df <- data.accum[data.accum$temp.group == i,]
#   plotname <- paste(prefix, "moist-resp-norm-", df$temp.group[1], ".", devname, sep = "")
#   plotfile <- file.path(savedir, plotname)
#   if(export) devfun(file = plotfile) #, width = 5, height = 5)
#   plot(C_R_orn ~ moist_vol, data = df, main = df$temp.group[1], 
#        xlim = c(0,0.5), ylim=c(0,2), col = 2, pch = 16,
#        xlab = "Soil Moisture (m3/m3)", ylab = "Respired CO2 (normalized)")
#   points(C_R_mrn ~ moist_vol, data = df, col = 7, pch = 16)
#   lines (y.o ~ x$moist_vol, col = 2)
#   lines (y.m ~ x$moist_vol, col = 7)
# }
# 
# Plot absolute values for each temp group ----------------------------------------
for (i in names(fit.moist.obs)) {
  df <- data.accum[data.accum$temp.group == i,]
  plotname <- paste(prefix, "moist-resp-", df$temp.group[1], ".", devname, sep = "")
  plotfile <- file.path(savedir, plotname)
  if(export) devfun(file = plotfile) #, width = 5, height = 5)
  plot(C_R_ro ~ moist_vol, data = df, main = df$temp.group[1],
       xlim = c(0,0.5), col = 2, pch = 16,
       xlab = "Soil Moisture (m3/m3)", ylab = "Respired CO2 (mgC m-3 h-1)")
  points(C_R_rm ~ moist_vol, data = df, col = 7, pch = 16)
}

# Plot each moist group -----------------------------------------------------
# x <- data.frame(temp = seq(0, 35, 1))
# for (i in names(fit.temp.obs)) {
#   # e.o <- predict(fit.temp.obs[[i]]$fitEa, newdata = x)
#   # e.m <- predict(fit.temp.mod[[i]]$fitEa, newdata = x)
#   # q.o <- predict(fit.temp.obs[[i]]$fitQ10, newdata = x)
#   # q.m <- predict(fit.temp.mod[[i]]$fitQ10, newdata = x)
#   df <- data.accum[data.accum$moist.group == i,]
#   plotname <- paste(prefix, "moist-resp-", df$moist.group[1], ".", devname, sep = "")
#   plotfile <- file.path(savedir, plotname)
#   if(export) devfun(file = plotfile) #, width = 5, height = 5)
#   plot(C_R_ro ~ temp, data = df, main = df$moist.group[1], xlim=c(0,40),  col = 2, pch = 16)
#   points(C_R_rm ~ temp, data = df, col = 7, pch = 16)
#   # lines (e.o ~ x$temp, col = 2)
#   # lines (e.m ~ x$temp, col = 7)
# #   lines (q.o ~ x$temp, col = 2)
# #   lines (q.m ~ x$temp, col = 8)
# }


# Plot pararameters for temp function -------------------------------------------
PlotTR <- function(naming, fit.pars, TR, ylab) {
  plotname <- paste(prefix, naming, devname, sep = "")
  plotfile <- file.path(savedir, plotname)
  if(export) devfun(file = plotfile) #, width = 5, height = 5)
  p <- ggplot(data = fit.pars, aes_string(x='moist_vol', y=TR, colour='site')) +
    geom_point(size = 3) +
    ylab(ylab) +
    xlab("Soil Moisture (m3/m3)") +
    theme(legend.justification=c(1,1), legend.position=c(1,1)) +
    geom_line()
  # geom_smooth(linetype=0, span=span, se=FALSE)
  print(p)
}

span = 0.5
TR='Q10'   # Either 'Q10' or 'Ea'
ylabel <- paste("Apparent Temperature Sensitivity ", TR)
# For observed data
fit.pars <- fit.temp.obs
PlotTR(paste0(TR, "_obs."), fit.pars, TR, ylabel)
# For observed data 5-20
fit.pars <- fit.temp.obs.5_20
PlotTR(paste0(TR, "_obs.5_20."), fit.pars, TR, ylabel)
# For observed data 20-35
fit.pars <- fit.temp.obs.20_35
PlotTR(paste0(TR, "_obs.20_35."), fit.pars, TR, ylabel)

try({
  # For modeled data
  fit.pars <- fit.temp.mod
  PlotTR(paste0(TR, "_mod."), fit.pars, TR, ylabel) 
})
try({
  # For modeled data 5-20
  fit.pars <- fit.temp.mod.5_20
  PlotTR(paste0(TR, "_mod.5_20."), fit.pars, TR, ylabel)
})
try({
  # For modeled data 20_35
  fit.pars <- fit.temp.mod.20_35
  PlotTR(paste0(TR, "_mod.20_35."), fit.pars, TR, ylabel)
})

# Plot T-response of decomposition flux
try({
  # For modeled data
  fit.pars <- fit.temp.decomp
  PlotTR(paste0(TR, "_decomp."), fit.pars, TR, ylabel) 
})
try({
  # For modeled data 5-20
  fit.pars <- fit.temp.decomp.5_20
  PlotTR(paste0(TR, "_decomp.5_20."), fit.pars, TR, ylabel)
})
try({
  # For modeled data 20_35
  fit.pars <- fit.temp.decomp.20_35
  PlotTR(paste0(TR, "_decomp.20_35."), fit.pars, TR, ylabel)
})


if(export) while(dev.cur() > 1) dev.off()

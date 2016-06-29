### ===================================== ###
### Analyze and plot model vs observation ###
### ===================================== ###

### Libraries
require(plyr)
require(reshape2)
library(ggplot2)

prefix <- "plot"
savedir <- file.path("..", "NadiaTempMoist", "plots")
devname <- "png"
devfun <- png
export <- 1

# # Plot residuals
# palette("default")
# plot(res, col = data.accum$temp, main = "By Temperature")
# plot(res, col = as.factor(data.accum$moist_vol), main = "By Moisture")
# plot(res, col = data.accum$site, main = "By Site")

# Plot accumulated model vs data
plotname <- paste(prefix, "-accum_mod_obs.", devname, sep = "")
plotfile <- file.path(savedir, plotname)
if(export) devfun(file = plotfile) #, width = 5, height = 5)
plot(data.accum$C_R_o, data.accum$C_R_m, col = data.accum$site,
     xlab = "Observed Accumulated CO2 (gC)", ylab = "Modeled Accumulated CO2 (gC)")
lines(c(0,1),c(0,1))

# # Plot rates model vs data
# plotname <- paste(prefix, "-rates_mod_obs.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# plot(data.accum$C_R_or, data.accum$C_R_mr, col = data.accum$site, 
#      xlab = "Observed Respired CO2 (mgC h-1 m-3)", ylab = "Modeled Respired CO2 (mgC h-1 m-3)")
# lines(c(0,1),c(0,1))

# # Plot rates model vs data adding non-calibrated values
# calib.accum.obs.r <- data.accum$C_R_or
# calib.accum.mod.r <- data.accum$C_R_mr
# # Run with init pars here!!!
# palette("default")
# # Plot rates model vs data
# plotname <- paste(prefix, "-rates_mod_obs.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# plot(data.accum$C_R_or, data.accum$C_R_mr, col = "gray",
#      xlab = "Observed Respired CO2 (mgC h-1 m-3)", ylab = "Modeled Respired CO2 (mgC h-1 m-3)")
# points(calib.accum.obs.r, calib.accum.mod.r, col = "green")
# lines(c(0,1),c(0,1))


cv <- rainbow(10, alpha = 0.5)  # heat.colors(10, alpha = 0.5)
palette(cv)

# # Plot normalized values for each temp group
# x <- data.frame(moist_vol = seq(0.01, 0.5, 0.001))
# for (i in names(fit.moist.obs)) {
#   y.o <- predict(fit.moist.obs[[i]]$fit, newdata = x)
#   y.m <- predict(fit.moist.mod[[i]]$fit, newdata = x)
#   df <- data.accum[data.accum$temp.group == i,]
#   plotname <- paste(prefix, "-moist-resp-norm-", df$temp.group[1], ".", devname, sep = "")
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
# Plot absolute values for each temp group
for (i in names(fit.moist.obs)) {
  df <- data.accum[data.accum$temp.group == i,]
  plotname <- paste(prefix, "-moist-resp-", df$temp.group[1], ".", devname, sep = "")
  plotfile <- file.path(savedir, plotname)
  if(export) devfun(file = plotfile) #, width = 5, height = 5)
  plot(C_R_or ~ moist_vol, data = df, main = df$temp.group[1],
       xlim = c(0,0.5), col = 2, pch = 16,
       xlab = "Soil Moisture (m3/m3)", ylab = "Respired CO2 (mgC m-3 h-1)")
  points(C_R_mr ~ moist_vol, data = df, col = 7, pch = 16)
}

# # Plot each moist group
# x <- data.frame(temp = seq(0, 35, 1))
# for (i in names(fit.temp.obs)) {
#   e.o <- predict(fit.temp.obs[[i]]$fitEa, newdata = x)
#   e.m <- predict(fit.temp.mod[[i]]$fitEa, newdata = x)
#   q.o <- predict(fit.temp.obs[[i]]$fitQ10, newdata = x)
#   q.m <- predict(fit.temp.mod[[i]]$fitQ10, newdata = x)
#   df <- data.accum[data.accum$moist.group == i,]
#   plotname <- paste(prefix, "-moist-resp-", df$moist.group[1], ".", devname, sep = "")
#   plotfile <- file.path(savedir, plotname)
#   if(export) devfun(file = plotfile) #, width = 5, height = 5)
#   plot(C_R_or ~ temp, data = df, main = df$moist.group[1], xlim=c(0,40),  col = 2, pch = 16)
#   points(C_R_mr ~ temp, data = df, col = 7, pch = 16)
#   lines (e.o ~ x$temp, col = 2)
#   lines (e.m ~ x$temp, col = 7)
# #   lines (q.o ~ x$temp, col = 2)
# #   lines (q.m ~ x$temp, col = 8)
# }


## Plot pararameters for temp function
# # For observed data
# span=0.5
# fit.pars <- ldply(fit.temp.obs, function(x) {data.frame(Ea = x$Ea, Q10 = x$Q10, site = x$site, moist_vol = x$moist_vol)})
# 
# plotname <- paste(prefix, "-Ea_obs.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# p1 <- ggplot(data = fit.pars, aes(x=moist_vol, y=Ea, colour=site)) +
#   geom_point(size = 3) +
#   ylab("Apparent Temperature Sensitivity, Ea (kJ)") +
#   xlab("Soil Moisture (m3/m3)") +
#   theme(legend.justification=c(1,1), legend.position=c(1,1)) +
#   ylim(30, 80) +
#   geom_line()
#   geom_smooth(linetype=0, span=span, se=F)
# print(p1)

# plotname <- paste(prefix, "-Q10_obs.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# p2 <- ggplot(data=fit.pars, aes(x=moist_vol, y=Q10, colour=site)) +
#   geom_point(size = 3) +
#   ylab("Apparent Temperature Sensitivity, Q10") +
#   xlab("Soil Moisture (m3/m3)") +
#   theme(legend.justification=c(1,1), legend.position=c(1,1)) +
#   ylim(1.6, 3) +
#   geom_line()
#   # geom_smooth(span=span, se=FALSE)
# print(p2)

# For modeled data
fit.pars <- ldply(fit.temp.mod, function(x) {data.frame(Ea = x$Ea, Q10 = x$Q10, site = x$site, moist_vol = x$moist_vol)})

plotname <- paste(prefix, "-Ea_mod.", devname, sep = "")
plotfile <- file.path(savedir, plotname)
if(export) devfun(file = plotfile) #, width = 5, height = 5)
p3 <- ggplot(data = fit.pars, aes(x=moist_vol, y=Ea, colour=site)) +
  geom_point(size = 3) +
  ylab("Apparent Temperature Sensitivity, Ea (kJ)") +
  xlab("Soil Moisture (m3/m3)") +
  theme(legend.justification=c(1,1), legend.position=c(1,1)) +
  ylim(30, 80) +
  geom_line()
  # geom_smooth(linetype=0, span=span, se=FALSE)
print(p3)

# plotname <- paste(prefix, "-Q10_mod.", devname, sep = "")
# plotfile <- file.path(savedir, plotname)
# if(export) devfun(file = plotfile) #, width = 5, height = 5)
# p4 <- ggplot(data=fit.pars, aes(x=moist_vol, y=Q10, colour=site)) +
#   geom_point(size = 3) +
#   ylab("Apparent Temperature Sensitivity, Q10") +
#   xlab("Soil Moisture (m3/m3)") +
#   theme(legend.justification=c(1,1), legend.position=c(1,1)) +
#   ylim(1.6, 3) +
#   geom_line()
#   # geom_smooth(span=span, se=FALSE)
# print(p4)

# # Fit model 2: here I fix K and Th and use a "p1" that modifies 
# # the 'diffusion' directly, and "n" for the shape of the curve.
# # Th is taken from model 1 fits or can be fixed at different values.
# #   fit<-nls(
#     C_R_orn~Rmax * ifelse((moist_vol - Th)<0, 0, ((moist_vol - Th)^n * p1) / (K + (moist_vol - Th)^n * p1)),
#     start=c(p1=1, n=2),
#     algorithm="port",
#     data=df)

if(export) while(dev.cur() > 1) dev.off()

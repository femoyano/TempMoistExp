library(plyr)
library(reshape2)
library(ggplot2)

# Get accumulated values to match observations and merge datasets
data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum),
   by.x = c("treatment", "hour"), by.y = c("treatment", "time"))
data.accum$C_R_rm <- data.accum$C_R_m / data.accum$time_accum # convert to hourly rates [gC kg-1 h-1]
data.accum$C_R_ro <- data.accum$C_R_r  # Observed data should be already gC kg-1 h-1
data.accum$C_dec_r <- data.accum$C_dec / data.accum$time_accum # convert to hourly rates [gC kg-1 h-1]
data.accum$C_R <- NULL
# Convert to mg kg-1 h-1
data.accum$C_R_ro <- data.accum$C_R_ro * 1000
data.accum$C_R_rm <- data.accum$C_R_rm * 1000


## ------------------------------------------------- ##
##  Do some statistics and simple comparisons      ----
## ------------------------------------------------- ##

# Get RMSE and MAE
res <- data.accum$C_R_ro - data.accum$C_R_m
RMSE <- sqrt(mean(res^2))
MAE <- mean(abs(res))

## ------------------------------------------------- ##
##         Fit simple models           ----
## ------------------------------------------------- ##
cv <- rainbow(10, alpha = 0.5)  # heat.colors(10, alpha = 0.5)
palette(cv)
# define subsets of data:
data.accum$temp.group <- interaction(data.accum$site, data.accum$temp) # create a group variable
data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable

# Fit temperature response models -----------
fitExpfun <- function(df, Q10) { nls(x ~ a * Q10^(temp/10), start=list(a=0.01, Q10=Q10),
                                     data = df, na.action = na.exclude) }
fitArrfun <- function(df, Ea) { nls(x ~ a * exp(-Ea/0.008314*(1/(temp+273) - 1/273)),
                                    start=c(a = 0.1, Ea = Ea), data = df) }

# Fit a temprature function to each moisture subgroup and plot
FitTemp <- function(df, var, set, trange) {
  # browser()
  texc <- -99; if(trange=='5-20') texc <- 35; if(trange=='20-35') texc <- 5
  df <- df[df$temp!=texc,]
  df$x <- df[[var]]
  fitExp <- try(fitExpfun(df, 1))
  if(class(fitExp)=="try-error") fitExp <- try(fitExpfun(df, 3))
  if(class(fitExp)=="try-error") fitExp <- try(fitExpfun(df, 6))
  if(class(fitExp)!="try-error") {Q10 = coef(fitExp)[[2]]; R0 = coef(fitExp)[[1]]} else {Q10 = NA; R0 = NA }
  fitArr <- try(fitArrfun(df, 100))
  if(class(fitArr)=="try-error") fitArr <- try(fitArrfun(df, 40))
  if(class(fitArr)!="try-error") {A = coef(fitArr)[[1]]; Ea = coef(fitArr)[[2]]} else {A = NA; Ea = NA}
  out <- data.frame(set = set, trange = trange, site = df$site[1], var = var, moist_vol = df$moist_vol[1], Q10 = Q10, R0 = R0, A = A, Ea = Ea)
}

# for(data.accum in c(data.accum_mmr1, data.accum_mmr0cubic, data.accum_mmr0hama))
# Fits for respired or decomposed C with temperature for different temperature ranges
fit.temp <- ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_ro", set = 'obs', trange = '5-35')
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_rm", set = 'mod', trange = '5-35'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_ro", set = 'obs', trange = '5-20'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_rm", set = 'mod', trange = '5-20'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_ro", set = 'obs', trange = '20-35'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_rm", set = 'mod', trange = '20-35'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_dec_r", set = 'mod', trange = '5-35'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_dec_r", set = 'mod', trange = '5-20'))
fit.temp <- rbind(fit.temp, ddply(data.accum, .(moist.group), .fun = FitTemp, var = "C_dec_r", set = 'mod', trange = '20-35'))


## Plots --------------------------------------------------------------------

prefix <- "plot_"
savedir <- file.path("plots")
devname <- "png"
devfun <- png
export <- 1
opar <- par(no.readonly=TRUE)

cv <- rainbow(10, alpha = 0.5)  # heat.colors(10, alpha = 0.5)
palette(cv)

# Plot accumulated model vs data --------------------------------------------------
plotname <- paste(prefix, "accum_mod_obs.", devname, sep = "")
plotfile <- file.path(savedir, plotname)
if(export) devfun(file = plotfile) #, width = 5, height = 5)
plot(data.accum$C_R_ro, data.accum$C_R_rm, col = data.accum$site,
     xlab = "Observed Accumulated CO2 (gC)", ylab = "Modeled Accumulated CO2 (gC)")
lines(c(0,1),c(0,1))

# Plot absolute values for each temp group ----------------------------------------
for (i in unique(data.accum$temp.group)) {
  df <- data.accum[data.accum$temp.group == i,]
  plotname <- paste(prefix, "moist-resp-", df$temp.group[1], ".", devname, sep = "")
  plotfile <- file.path(savedir, plotname)
  if(export) devfun(file = plotfile) #, width = 5, height = 5)
  plot(C_R_ro ~ moist_vol, data = df, main = df$temp.group[1],
       xlim = c(0,0.5), col = 2, pch = 16,
       xlab = "Soil Moisture (m3/m3)", ylab = "Respired CO2 (mgC m-3 h-1)")
  points(C_R_rm ~ moist_vol, data = df, col = 7, pch = 16)
}

# Plot pararameters for temp function -------------------------------------------
PlotTR <- function(fits, TR, pal, trange) {
  # browser()
  fits <- fits[fits$trange==trange,]
  palette(pal)
  fits$group <- paste(fits$site, fits$trange)
  # fits$group <- factor(fits$group, levels = c("maize 20-35", "bare_fallow 20-35", 'maize 5-20',  'bare_fallow 5-20'))
  if(TR == 'Ea') ylab <- expression(paste(E[a], ' (kJ)')) else ylab <- expression(Q[10])
  plotname <- paste0(prefix, TR, '_', trange, '.', devname)
  plotfile <- file.path(savedir, plotname)
  if(export) devfun(file = plotfile, width = 1200, height = 600)
  p <- ggplot(data = fits, aes_string(x='moist_vol', y=TR, group='var',
                                      colour='var', shape='var')) + #, linetype='var')) +
    scale_color_manual(values=pal) +
    scale_linetype_manual(values=c("solid", "longdash")) +
    theme_bw(base_size = 30) +
    geom_line(size = 1.3) +
    # geom_smooth(size = 1.5, span=0.3, se=FALSE) +
    geom_point(size = 6) +
    geom_point(size = 3, colour='white') +
    ylab(ylab) +
    xlab(expression(paste("Soil Moisture ", (m^3*m^-3)))) +
    theme(legend.justification=c(1,1), legend.position=c(1,1),
          legend.box='horizontal', legend.background = element_rect(colour = "grey"),
          legend.title = element_blank(), legend.key.height=unit(1.5,'cm'), legend.key.width=unit(3,'cm')) +
    facet_wrap(~group) #, scales = 'free_y')
  print(p)
}

for(TR in c('Ea')) {
  pal <- c('olivedrab3', 'olivedrab4', 'orange3')
  PlotTR(fit.temp, TR, pal, '5-20')
  PlotTR(fit.temp, TR, pal, '20-35')
  PlotTR(fit.temp, TR, pal, '5-35')
}

if(export) while(dev.cur() > 1) dev.off()



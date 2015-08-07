# Plot results ================================================================
year  <- 31536000 # seconds in a year
month <- 2628000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
#===============================================================================

# === set plotting time interval === #
plot.time <- month
# ================================== #

out.agg <- aggregate(out, by=list(x=ceiling(out[,1]*tstep/plot.time)), FUN=mean)

# png()
t <- "p"
plot(out.agg$PC, type=t) #/out.agg$PC[1]-1) * 100, ylim=c(-50,50), xlim=c(0,100), type=t)
plot(out.agg$SCw, type=t)
plot(out.agg$SCs, type=t)
plot(out.agg$ECb, type=t)
plot(out.agg$ECm, type=t)
plot(out.agg$ECs, type=t)
plot(out.agg$CO2, type=t)

# graphics.off()

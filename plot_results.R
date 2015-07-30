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

plot(out.agg$PC) #/out.agg$PC[1]-1) * 100, ylim=c(-50,50), xlim=c(0,100), type="l")
plot(out.agg$SCb)
plot(out.agg$SCm)
plot(out.agg$SCs)
plot(out.agg$MC)
plot(out.agg$ECb)
plot(out.agg$ECm)
plot(out.agg$ECs)
plot(out.agg$CO2)

# # 
# plot(out$PC)
# plot(out$SC)
# plot(out$MC)
# plot(out$EC)
# plot(out$CO2)
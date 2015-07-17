# Plot results ================================================================
year  <- 31536000 # seconds in a year
month <- 2628000  # seconds in a month
day   <- 86400    # seconds in a day
hour  <- 3600     # seconds in an hour
#===============================================================================

plot.time <- year
out.agg <- aggregate(model.out, by=list(x=ceiling(model.out[,1]*tunit/plot.time)), FUN=mean)

plot((out.agg$PC/out.agg$PC[1]-1) * 100, ylim=c(-50,50), xlim=c(0,100), type="l")
plot(out.agg$SC)
plot(out.agg$MC)
plot(out.agg$EC)
plot(out.agg$CO2)

# 
# plot(model.out$PC)
# plot(model.out$SC)
# plot(model.out$MC)
# plot(model.out$EC)
# plot(model.out$CO2)
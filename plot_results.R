# Plot results ====
out.agg <- aggregate(model.out, by=list(x=ceiling(model.out[,1]*tunit/month)), FUN=mean)

plot(out.agg$PC)
plot(out.agg$SC)
plot(out.agg$MC)
plot(out.agg$EC)
plot(out.agg$CO2)

out293.agg <- out.agg

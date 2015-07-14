# Plot results ====
out.days <- aggregate(model.out, by=list(x=ceiling(model.out[,1]/24)), FUN=mean)

plot(out.days$PC)
plot(out.days$SC)
plot(out.days$MC)
plot(out.days$EC)
plot(out.days$CO2)


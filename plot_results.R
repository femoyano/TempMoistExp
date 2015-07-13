# Plot results ====
out.month <- aggregate(model.out, by=list(x=ceiling(model.out[,1]/24)), FUN=mean)

plot(out.month$PC)
plot(out.month$SC)
plot(out.month$MC)
plot(out.month$EC)
plot(out.month$CO2)


nbox <- 100
Length <- 100000 # m
dx <- Length/nbox # m
IntDist <- seq(0,by=dx,length.out=nbox+1) # m
Dist <- seq(dx/2,by=dx,length.out=nbox) # m
IntArea <- 4000 + 76000 * IntDist^5 /(IntDist^5+50000^5)
Area <- 4000 + 76000 * Dist^5 /(Dist^5+50000^5)
Volume <- Area*dx # m3
Eriver <- 0
Esea <- 350*3600*24
E <- Eriver + IntDist/Length * Esea # m2/d
Estar <- E * IntArea/dx

fZooTime = c(0, 30,60,90,120,150,180,210,240,270,300,340,367)
fZooConc = c(20,25,30,70,150,110, 30, 60, 50, 30, 10, 20, 20)
# the model parameters:
pars <-  c(riverZoo = 0.0,
         g  =-0.05,
         meanFlow = 100*3600*24,
         ampFlow = 50*3600*24,
         phaseFlow  = 1.4)

require(deSolve)
Zootran <-function(t,Zoo,pars)
{
  with (as.list(pars),{
    Flow <- meanFlow+ampFlow*sin(2*pi*t/365+phaseFlow)
    seaZoo <- approx(fZooTime, fZooConc, xout=t)$y
    Input <- +Flow * c(riverZoo, Zoo) +
      -Estar* diff(c(riverZoo, Zoo, seaZoo))
    dZoo <- -diff(Input)/Volume + g*Zoo
    list(dZoo)
  })
}

ZOOP <- rep(0,times=nbox)
times <- 1:365
out <- ode.band(times=times,y=ZOOP,func=Zootran,parms=pars,nspec=1)

par(oma=c(0,0,3,0)) # set margin size
filled.contour(x=times,y=Dist/1000,z=out[,-1],
               color= terrain.colors,xlab="time, days",
               ylab= "Distance, km",main="Zooplankton, mg/m3")
mtext(outer=TRUE,side=3,"Marine Zooplankton in the Scheldt",cex=1.5)


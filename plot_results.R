PlotResults <- function(out) {
  year  <- 31104000 # seconds in a year
  month <- 2592000  # seconds in a month
  day   <- 86400    # seconds in a day
  hour  <- 3600     # seconds in an hour
  tstep <- hour
  agg.time <- day
  
  out.agg <- aggregate(out, by=list(x=ceiling(out[,1]*tstep/agg.time)), FUN=mean)

  # png()
  t <- "p"
  plot(out.agg$PC, type=t) #/out.agg$PC[1]-1) * 100, ylim=c(-50,50), xlim=c(0,100), type=t)
#   plot(out.agg$SCw, type=t)
#   plot(out.agg$SCs, type=t)
#   plot(out.agg$ECb, type=t)
#   plot(out.agg$ECm, type=t)
#   plot(out.agg$ECs, type=t)
  plot(out.agg$CO2, type=t)
  plot(out.agg$TOC, type=t)
#   plot(out.agg$temp, type=t)
#   plot(out.agg$moist, type=t)
#   plot((out.agg$PC / out.agg$PC[1]-1) * 100, type=t, ylim=c(-15,15), xlim=c(0,100))
#   plot((out.agg$TOC / out.agg$TOC[1]-1) * 100, type=t, ylim=c(-15,15), xlim=c(0,100))
  
  # graphics.off()
}

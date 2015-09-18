PlotResults <- function(data, agg.time, path, name) {

  year  <- 31104000 # seconds in a year
  month <- 2592000  # seconds in a month
  day   <- 86400    # seconds in a day
  hour  <- 3600     # seconds in an hour
  tstep <- hour
  agg_t <- get(agg.time)
  
  data.agg <- aggregate(data, by=list(x=ceiling(data[,1]*tstep/agg_t)), FUN=mean)

  ty <- "l"
  vars <- names(data.agg)
  for (i in 3:length(vars)) {
    fname <- paste(path, name, "_", vars[i],".png",sep="")
    png(filename = fname)
    plot(data.agg[,i], type=ty, xlab = agg.time, ylab=vars[i])
    graphics.off()
    
    # plot relative changes
    if(vars[i] == "TOC" | vars[i] == "PC") {
      fname <- paste(path, name, "_", vars[i],"_relative.png",sep="")
      png(filename = fname)
      plotdata <- (data.agg[,i] / data.agg[1,i] - 1) * 100
      plot(plotdata, type=ty, ylim=c(-15,15), xlab = agg.time, ylab=vars[i])
      graphics.off()
    }
  }
}

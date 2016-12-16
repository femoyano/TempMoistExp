# Plots showing the time sequence of decomposed and respired C, and temperature.

df.out <- as.data.frame(mod.out)
for (i in unique(df.out$treatment)) {
  df  <- df.out[df.out$treatment==i,]
  sum <- input.all[input.all$treatment==i,]
  title <- paste(sum$site[1], sum$moist[1], sep = "-")
  par(mar = c(5,5,2,5))
  plot(df$decomp, type = 'l', main = title, ylim = c(0,2.5))
  lines(df$C_R, col=4)
  par(new=T)
  plot((df$temp-273), col=2, type = 'l', axes=F, xlab=NA, ylab=NA, ylim = c(0,35))
  axis(side = 4)
  mtext(side = 4, line = 3, 'Temperature')
}


# Random plotting
out <- as.data.frame(mod.out)

# Converting to mgC (note that optimization code already converts to gC kg-1 h-1)
out_raw <- out
# out[,c(2:8, 12:13)] <- out_raw[,c(2:8, 12:13)] * 1000

# Correlation decomposed vs respired
pal <- topo.colors # c('#9ACD32', '#698B22', '#CD8500') # 'olivedrab3', 'olivedrab4', 'orange3'
ggplot(data = out, aes(x=C_dec, y=C_R, group=treatment,
     colour=moist)) +
  # scale_linetype_manual(values=c("solid", "longdash")) +
  scale_colour_gradientn(colours = c('#E9967A', '#1E90FF')) + # terrain.colors
  geom_line(size = 1.3) +
  ylab(expression(paste("Total respired C (g C)"))) +
  xlab(expression(paste("Decomposed C (g C)"))) +
  theme_bw(base_size = 12) +
  theme(legend.justification=c(1,1), legend.position=c(0.25,1),
        legend.box='horizontal',
        legend.background = element_rect(colour = "grey"),
        # legend.title = element_blank(), 
        legend.key.height=unit(0.7,'cm'), legend.key.width=unit(1.2,'cm'),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank())

        
# # Plots showing the time sequence of decomposed and respired C, and temperature.
# for (i in unique(out$treatment)) {
#   df  <- out[out$treatment==i,]
#   sum <- input.all[input.all$treatment==i,]
#   title <- paste(sum$site[1], sum$moist[1], sep = "-")
#   par(mar = c(5,5,2,5))
#   plot(df$C_dec, type = 'l', main = title, ylim = c(0,2.5))
#   lines(df$C_R, col=4)
#   par(new=T)
#   plot((df$temp-273), col=2, type = 'l', axes=F, xlab=NA, ylab=NA, ylim = c(0,35))
#   axis(side = 4)
#   mtext(side = 4, line = 3, 'Temperature')
# }
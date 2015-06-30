# auxiliary_functions.r

# Artificial temperature forcing data (from Tang and Riley 2014)
temp.forcing <- data.frame(days = seq(1,365,0.05))
temp.forcing$temp <- 290 - 10*cos(2*pi/365*temp.forcing$days) + 8 * sin(2 * pi * temp.forcing$days)

forcing <- read.csv("Hainich_ST-SM_2014_Jan-Oct.csv")
moist.forcing <- moist.forcing[,c(1,12)]

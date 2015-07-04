# inputs

### Climate forcing and litter input
forcing.data   <- read.csv("forcing_data_daily.csv") # forcing data file
litter.data    <- read.csv("litter_input_daily.csv") # litter input rates file

### Spatial Variables
clay   <-  0.51  # [g g^-1] clay fraction values 
sand   <-  0.03  # [g g^-1] sand fraction values 
silt   <-  0.46  # [g g^-1] silt fraction values 
depth  <-  0.30  # [m] soil depth

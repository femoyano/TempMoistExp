### ===================================== ###
### Analyze and plot model vs observation ###
### ===================================== ###

### Libraries
require(deSolve)
require(FME)
require(plyr)
require(reshape2)
library(doParallel)
library(ggplot2)

cores = detectCores()
registerDoParallel(cores = cores)

## ------------------------------------ ##
##              Functions             ----
## ------------------------------------ ##

# Function that returns Root Mean Squared Error
rmse <- function(res) sqrt(mean(res^2))

# Function that returns Mean Absolute Error
mae <- function(res) mean(abs(res))


## ------------------------------------ ##
##  Check parameter sensitivities     ----
## ------------------------------------ ##

par_corr_plot <- pairs(Sfun, which = c("C_R"), col = c("blue", "green"))
ident <- collin(Sfun)
ident_plot <- plot(ident, ylim=c(0,20))
ident[ident$N==9 & ident$collinearity<15,]


## ------------------------------------ ##
### -------- Get model data ----------- ##           
## ------------------------------------ ##

# Prepare setup

list2env(setup, envir = .GlobalEnv)
### Define time variables
year     <- 31104000 # seconds in a year
hour     <- 3600     # seconds in an hour
sec      <- 1        # seconds in a second!
# Other settings
tstep <- get(t_step)
tsave <- get(t_save)
spinup     <- FALSE
eq.stop    <- FALSE   # Stop at equilibrium?
# Input Setup -----------------------------------------------------------------
input_path    <- file.path(".")  # ("..", "Analysis", "NadiaTempMoist")
data.samples  <- read.csv(file.path(input_path, sample_list_file))
input.all     <- read.csv(file.path(input_path, "mtdata_model_input.csv"))
obs.accum     <- read.csv(file.path(input_path, "mtdata_co2.csv"))
site.data.mz  <- read.csv(file.path(input_path, "site_Closeaux.csv"))
site.data.bf  <- read.csv(file.path(input_path, "site_BareFallow42p.csv"))
obs.accum <- obs.accum[obs.accum$sample %in% data.samples$sample,]
### Sourced required files ----------------------------------------------------
source("parameters.R")
source(pars_optim_file)
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")
source("initial_state.R")
source("AccumCalc.R")
source("SampleRun.R")
source("GetModelData.R")
costfun <- ModCost # Return modCost object or residuals? Processing is somewhat different

# Get model output with optimized parameters
mod.out <- GetModelData(input.all, fitMod$par)

# Get accumulated values to match observations and merge datasets
data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"), by.y = c("sample", "time"))
data.accum$C_R_o <- data.accum$C_R
data.accum$C_R <- NULL


## ------------------------------------------------- ##
##  Do some statistics and simple comparisons      ----
## ------------------------------------------------- ##

# Get RMSE and MAE
res <- data.accum$C_R - data.accum$C_R_m
RMSE <- rmse(res)
MAE <- mae(res)
# Plot residuals
plot(res, col = data.accum$temp)
plot(res, col = data.accum$moist)
plot(res, col = data.accum$site)

# Plot model vs data
plotname <- paste("mod-obs", savetime, "png", sep = "_")
plotfile <- file.path("..", "Analysis", "NadiaTempMoist", plotname)
# png(file = plotfile)
plot(data.accum$C_R, data.accum$C_R_m, col = data.accum$site)


## ------------------------------------------------- ##
##         Calculate rates and normalize           ----
## ------------------------------------------------- ##

# Calculate the rates for each accumulated period
data.accum$C_R_or <- data.accum$C_R_o / data.accum$time_accum
data.accum$C_R_mr <- data.accum$C_R_m / data.accum$time_accum

## Normalize values using maximums of polynomial fits (both cycles combined)
# define the function
fun.norm <- function (df) {
  pol <- lm(C_R ~ poly(moist, 3), data = df)
  new <- data.frame(moist = seq(0.01, max(df$moist, na.rm = TRUE), 0.01))
  maxval <- max(predict(pol, newdata = new))
  df$C_R.norm <- df$C_R / maxval
  return(df)
}
tempdat  <- data.frame(moist = data.accum$moist_vol, C_R = data.accum$C_R_or)
norm.obs <- ddply(tampdat, .(site, temp), fun.norm) # apply the function
tempdat  <- data.frame(moist = data.accum$moist_vol, C_R = data.accum$C_R_mr)
norm.mod <- ddply(tampdat, .(site, temp), fun.norm) # apply the function
data.accum$C_R_orn <- norm.obs$C_R
data.accum$C_R_mrn <- norm.mod$C_R
rm(fun.norm, tempdat, norm.obs, norm.mod)


## ------------------------------------------------- ##
##         Fit simple nl models and plot           ----
## ------------------------------------------------- ##

## Fit model 1

data.accum$group.id <- interaction(data.accum$site, data.accum$temp) # create a group variable

model1 <- list() # prepare a list to store models

# prepare a dataframe to store parameter (Th = threshold)
results.mod <- data.frame(Th = vector(length=length(unique(data.accum$group.id))))

# fit models for each subset of data:
for (i in seq(along=unique(data.accum$group.id))) {
  df <- data.accum[data.accum$group.id==unique(data.accum$group.id)[i], ]
  fit<-nls(
    co2.norm ~ Rmax * ifelse((moist.vol - Th) < 0, 0, (moist.vol - Th)^2 / (K + (moist.vol - Th)^2)),
    start=c(Rmax=1, Th=0.01, K=0.01),
    lower=c(Rmax=0.5, Th=0, K=0.0001),
    upper=c(Rmax=1.5, Th=0.1, K=0.25),
    algorithm="port",
    data=df)
  #   print(summary(fit))
  model1[[i]]<-fit
  results.mod$Rmax[i] <- coef(model1[[i]])[1]
  results.mod$Th[i] <- coef(model1[[i]])[2]
  results.mod$K[i] <- coef(model1[[i]])[3]
  results.mod$Site[i] <- as.character(df$site[1])
  results.mod$Temperature[i] <- df$temp[1]
  # Comment/uncomment below to get plots of each model fit.
  plot(co2.norm~moist.vol, data=df, main=df$group.id[1],xlim=c(0,0.5))
  x <- data.frame(moist.vol=seq(0.01,0.5,0.001))
  y <- predict(fit, newdata=x)
  lines (y ~ x$moist.vol)
}

names(model1) <- unique(data.accum$group.id) # name each model

## Plot model 1

ggplot(data=results.mod, aes(x=Temperature, y=K, colour=Site)) +
  geom_point(size = 3) +
  geom_smooth(formula = y ~ poly(x,2), method=lm, se=FALSE)

ggplot(data=results.mod, aes(x=Temperature, y=Th, colour=Site)) +
  geom_point(size = 3) +
  geom_smooth(formula = y ~ poly(x,2), method=lm, se=FALSE)

rm(i, fit, x, y, df)


## Fit model 2: here I tried to fix K(e.g. 0.02) and add a parameter (p1) that modifies 
## the 'diffusion' directly. Th is taken from model 1 fits or can be fixed at different values.

model2 <- list()

for (i in seq(along=unique(data.accum$group.id))) {
  df <- data.accum[data.accum$group.id==unique(data.accum$group.id)[i], ]
  Rmax <- results.mod$Rmax[i]
  Th <- results.mod$Th[i] # Th can be set here
  K <- 0.01 # K can be set here
  fit<-nls(
    co2.norm~Rmax * ifelse((moist.vol - Th)<0, 0, ((moist.vol - Th)^2 * p1) / (K + (moist.vol - Th)^2 * p1)),
    start=c(p1=1),
    algorithm="port",
    data=df)
  #   print(summary(fit))
  model2[[i]]<-fit
  results.mod$p1[i] <- coef(model2[[i]])[1]
  plot(co2.norm~moist.vol, data=df, main=df$group.id[1],xlim=c(0,0.5))
  x <- data.frame(moist.vol=seq(0.01,0.5,0.001))
  y <- predict(fit, newdata=x)
  lines (y ~ x$moist.vol)
}
names(model2) <- unique(data.accum$group.id)

## Plot model 2

ggplot(data=results.mod, aes(x=Temperature, y=p1, colour=Site)) +
  geom_point(size = 3) +
  geom_smooth(formula = y ~ poly(x,2), method=lm, se=FALSE)

rm(Th, Rmax, K, i , fit, y, x)
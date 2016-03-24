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
##  Check parameter sensitivities     ----
## ------------------------------------ ##

# par_corr_plot <- pairs(Sfun, which = c("C_R"), col = c("blue", "green"))
# ident <- collin(Sfun)
# ident_plot <- plot(ident, ylim=c(0,20))
# ident[ident$N==9 & ident$collinearity<15,]


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
source(paste("pars", pars_optim, ".R", sep = ""))
source("flux_functions.R")
source("Model_desolve.R")
source("Model_stepwise.R")
source("initial_state.R")
source("GetModelData.R")

# Get model output with optimized parameters
system.time(mod.out <- GetModelData(fitMod$par))

# Get accumulated values to match observations and merge datasets
data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"), by.y = c("sample", "time"))
data.accum$C_R_o <- data.accum$C_R
data.accum$C_R <- NULL


## ------------------------------------------------- ##
##  Do some statistics and simple comparisons      ----
## ------------------------------------------------- ##

# Get RMSE and MAE
res <- data.accum$C_R_o - data.accum$C_R_m
RMSE <- sqrt(mean(res^2))
MAE <- mean(abs(res))

# Plot residuals
palette("default")
plot(res, col = data.accum$temp, main = "By Temperature")
plot(res, col = as.factor(data.accum$moist_vol), main = "By Moisture")
plot(res, col = data.accum$site, main = "By Site")

# Plot model vs data
plotname <- paste("mod-obs", savetime, "png", sep = "_")
plotfile <- file.path("..", "Analysis", "NadiaTempMoist", plotname)
# png(file = plotfile)
plot(data.accum$C_R_o, data.accum$C_R_m, col = data.accum$site)


## ------------------------------------------------- ##
##         Calculate rates and normalize           ----
## ------------------------------------------------- ##

# Calculate the rates for each accumulated period (* 1000 converts to mg)
data.accum$C_R_or <- data.accum$C_R_o / data.accum$time_accum * 1000
data.accum$C_R_mr <- data.accum$C_R_m / data.accum$time_accum * 1000

## Normalize values using maximums of polynomial fits (both cycles combined)
# define the function
fun.norm <- function (df) {
  pol <- lm(C_R ~ poly(moist_vol, 3), data = df)
  new <- data.frame(moist_vol = seq(0.01, max(df$moist_vol, na.rm = TRUE), 0.01))
  maxval <- max(predict(pol, newdata = new))
  df$C_R_norm <- df$C_R / maxval
  return(df)
}
data.accum$C_R <- data.accum$C_R_or
data.accum <- ddply(data.accum, .(site, temp), fun.norm) # apply the function
data.accum$C_R_orn <- data.accum$C_R_norm
data.accum$C_R <- data.accum$C_R_mr
data.accum <- ddply(data.accum, .(site, temp), fun.norm) # apply the function
data.accum$C_R_mrn <- data.accum$C_R_norm
rm(fun.norm)
data.accum$C_R <- NULL
data.accum$C_R_norm <- NULL


## ------------------------------------------------- ##
##         Fit simple nl models and plot           ----
## ------------------------------------------------- ##
cv <- rainbow(10, alpha = 0.5)  # heat.colors(10, alpha = 0.5)
palette(cv)
# define subsets of data:
data.accum$temp.group <- interaction(data.accum$site, data.accum$temp) # create a group variable
data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable

# Fit a moisture function to each temperatrue subgroup and plot
FitMoist <- function(df, var) {
    df$C_R <- df[[var]]
    fit <- nls(C_R ~ Rmax * ifelse((moist_vol - Th) < 0, 0, (moist_vol - Th)^2 / (K^2 + (moist_vol - Th)^2)),
               start=c(Rmax=1, Th=0.1, K=0.175), lower=c(Rmax=0.5, Th=0, K=0.01),
               upper=c(Rmax=1.5, Th=0.2, K=0.25), algorithm="port", data = df)
    return(list(fit = fit, Rmax = coef(fit)[1], Th = coef(fit)[2], K = coef(fit)[3],
                site = df$site[1], temp = df$temp[1]))
}
fit.moist.obs <- dlply(data.accum, .(temp.group), .fun = FitMoist, var = "C_R_orn")
fit.moist.mod <- dlply(data.accum, .(temp.group), .fun = FitMoist, var = "C_R_mrn")

# Plot each temp group
x <- data.frame(moist_vol = seq(0.01, 0.5, 0.001))
for (i in names(fit.moist.obs)) {
  y.o <- predict(fit.moist.obs[[i]]$fit, newdata = x)
  y.m <- predict(fit.moist.mod[[i]]$fit, newdata = x)
  df <- data.accum[data.accum$temp.group == i,]
  plot(C_R_orn ~ moist_vol, data = df, main = df$temp.group[1], xlim = c(0,0.5), ylim=c(0,2), col = 2, pch = 16)
  points(C_R_mrn ~ moist_vol, data = df, col = 7, pch = 16)
  lines (y.o ~ x$moist_vol, col = 2)
  lines (y.m ~ x$moist_vol, col = 7)
}

# Fit a temprature function to each moisture subgroup and plot
FitTemp <- function(df, var) {
  df$C_R <- df[[var]]
  fitEa <- nls(C_R ~ C_R_ref * exp(-Ea/0.008314*(1/(temp+273) - 1/273)),
             start=c(C_R_ref = 0.1, Ea = 60), algorithm="port", data = df)
  fitQ10 <- nls(C_R ~ C_R_ref * Q10^((temp-20)/10),
               start=c(C_R_ref = 0.1, Q10 = 2), lower = c(C_R_ref = 0, Q10 = 1),
               upper = c(C_R_ref = Inf, Q10 = Inf),
               algorithm="port", data = df)
  return(list(fitEa = fitEa, fitQ10 = fitQ10, C_R_ref = coef(fitEa)[1], Ea = coef(fitEa)[2],
              Q10 = coef(fitQ10)[2], site = df$site[1], moist_vol = df$moist_vol[1]))
}
fit.temp.obs <- dlply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_or")
fit.temp.mod <- dlply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_mr")

# Plot each moist group
x <- data.frame(temp = seq(0, 35, 1))
for (i in names(fit.temp.obs)) {
  e.o <- predict(fit.temp.obs[[i]]$fitEa, newdata = x)
  e.m <- predict(fit.temp.mod[[i]]$fitEa, newdata = x)
  q.o <- predict(fit.temp.obs[[i]]$fitQ10, newdata = x)
  q.m <- predict(fit.temp.mod[[i]]$fitQ10, newdata = x)
  df <- data.accum[data.accum$moist.group == i,]
  plot(C_R_or ~ temp, data = df, main = df$moist.group[1], xlim=c(0,40),  col = 2, pch = 16)
  points(C_R_mr ~ temp, data = df, col = 7, pch = 16)
  lines (e.o ~ x$temp, col = 2)
  lines (e.m ~ x$temp, col = 7)
#   lines (q.o ~ x$temp, col = 2)
#   lines (q.m ~ x$temp, col = 8)
}

### Plot of parameters ----

## Plot pararameters for moisture function
# For observed data
fit.pars <- ldply(fit.moist.obs, function(x) {data.frame(Rmax = x$Rmax, K = x$K, Th = x$Th, site = x$site, temperature = x$temp)})
ggplot(data = fit.pars, aes(x=temperature, y=K, colour=site)) +
  geom_point(size = 3) +
  geom_line()
# geom_smooth(formula = y ~ poly(x,2), method=lm, se=FALSE)
ggplot(data=fit.pars, aes(x=temperature, y=Th, colour=site)) +
  geom_point(size = 3) +
  geom_line()

# For modeled data
fit.pars <- ldply(fit.moist.mod, function(x) {data.frame(Rmax = x$Rmax, K = x$K, Th = x$Th, site = x$site, temperature = x$temp)})
ggplot(data = fit.pars, aes(x=temperature, y=K, colour=site)) +
  geom_point(size = 3) +
  geom_line()
# geom_smooth(formula = y ~ poly(x,2), method=lm, se=FALSE)
ggplot(data=fit.pars, aes(x=temperature, y=Th, colour=site)) +
  geom_point(size = 3) +
  geom_line()

## Plot pararameters for temp function
# For observed data
span=0.5
fit.pars <- ldply(fit.temp.obs, function(x) {data.frame(Ea = x$Ea, Q10 = x$Q10, site = x$site, moist_vol = x$moist_vol)})
ggplot(data = fit.pars, aes(x=moist_vol, y=Ea, colour=site)) +
  geom_point(size = 3) +
  # geom_line()
  geom_smooth(linetype=0, span=span, se=T)

# ggplot(data=fit.pars, aes(x=moist_vol, y=Q10, colour=site)) +
#   geom_point(size = 3) +
#   # geom_line()
#   geom_smooth(span=span, se=FALSE)

# For modeled data
fit.pars <- ldply(fit.temp.mod, function(x) {data.frame(Ea = x$Ea, Q10 = x$Q10, site = x$site, moist_vol = x$moist_vol)})
ggplot(data = fit.pars, aes(x=moist_vol, y=Ea, colour=site)) +
  geom_point(size = 3) +
  # geom_line()
  geom_smooth(linetype=0, span=span, se=T)

# ggplot(data=fit.pars, aes(x=moist_vol, y=Q10, colour=site)) +
#   geom_point(size = 3) +
#   # geom_line()
#   geom_smooth(span=span, se=FALSE)

# # Fit model 2: here I fix K and Th and use a "p1" that modifies 
# # the 'diffusion' directly, and "n" for the shape of the curve.
# # Th is taken from model 1 fits or can be fixed at different values.
# #   fit<-nls(
#     C_R_orn~Rmax * ifelse((moist_vol - Th)<0, 0, ((moist_vol - Th)^n * p1) / (K + (moist_vol - Th)^n * p1)),
#     start=c(p1=1, n=2),
#     algorithm="port",
#     data=df)

require(plyr)
require(reshape2)

mod.out[, 'decomp'] <- cumsum(mod.out[, 'F_cp.cd'])
mod.out[, 'decomp'] <- mod.out[, 'decomp'] / (parameters[["depth"]] * (1 - parameters[["ps"]]) * parameters[["pd"]] * 1000)  # converting to gC respired per kg soil


# Get accumulated values to match observations and merge datasets
data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("treatment", "hour"), by.y = c("treatment", "time"))
data.accum$C_R_rm <- data.accum$C_R_m / data.accum$time_accum # convert to hourly rates [gC kg-1 h-1]
data.accum$C_R_ro <- data.accum$C_R_r  # Observed data should be already gC kg-1 h-1
data.accum$C_R <- NULL
# Convert to mg kg-1 h-1
data.accum$C_R_ro <- data.accum$C_R_ro * 1000
data.accum$C_R_rm <- data.accum$C_R_rm * 1000


## ------------------------------------------------- ##
##  Do some statistics and simple comparisons      ----
## ------------------------------------------------- ##

# Get RMSE and MAE
res <- data.accum$C_R_ro - data.accum$C_R_m
RMSE <- sqrt(mean(res^2))
MAE <- mean(abs(res))


## ------------------------------------------------- ##
##         Calculate rates and normalize           ----
## ------------------------------------------------- ##

## Normalize values using maximums of polynomial fits (both cycles combined)
# define the function
fun.norm <- function (df) {
  pol <- lm(C_R ~ poly(moist_vol, 3), data = df)
  new <- data.frame(moist_vol = seq(0.01, max(df$moist_vol, na.rm = TRUE), 0.01))
  maxval <- max(predict(pol, newdata = new))
  df$C_R_norm <- df$C_R / maxval
  return(df)
}
data.accum$C_R <- data.accum$C_R_ro
data.accum <- ddply(data.accum, .(site, temp), fun.norm) # apply the function
data.accum$C_R_orn <- data.accum$C_R_norm
data.accum$C_R <- data.accum$C_R_rm
data.accum <- ddply(data.accum, .(site, temp), fun.norm) # apply the function
data.accum$C_R_mrn <- data.accum$C_R_norm
rm(fun.norm)
data.accum$C_R <- NULL
data.accum$C_R_norm <- NULL


## ------------------------------------------------- ##
##         Fit simple models           ----
## ------------------------------------------------- ##
cv <- rainbow(10, alpha = 0.5)  # heat.colors(10, alpha = 0.5)
palette(cv)
# define subsets of data:
data.accum$temp.group <- interaction(data.accum$site, data.accum$temp) # create a group variable
data.accum$moist.group <- interaction(data.accum$site, data.accum$moist_vol) # create a group variable

# Fit a moisture function to each temperature subgroup and plot
FitMoist <- function(df, var) {
  df$C_R <- df[[var]]
  fitfun <- function(df, Th) {nls(C_R ~ Rmax * ifelse((moist_vol - Th) < 0, 0, (moist_vol - Th)^2 / (K^2 + (moist_vol - Th)^2)),
                                  start=c(Rmax=1, Th=Th, K=0.15), lower=c(Rmax=0.5, Th=0, K=0.01),
                                  upper=c(Rmax=1.5, Th=0.25, K=0.25), algorithm="port", data = df)}
  fit <- try(fitfun(df, 0.1), silent = TRUE)
  if(class(fit)=="try-error") fit <- try(fitfun(df, 0.15), silent = TRUE)
  if(class(fit)=="try-error") fit <- try(fitfun(df, 0.2), silent = TRUE)
  if(class(fit)=="try-error") {return(NA)} else {return(list(fit = fit, Rmax = coef(fit)[1], Th = coef(fit)[2],
                                                             K = coef(fit)[3], site = df$site[1], temp = df$temp[1]))}
}
fit.moist.obs <- dlply(data.accum, .(temp.group), .fun = FitMoist, var = "C_R_orn")
fit.moist.mod <- dlply(data.accum, .(temp.group), .fun = FitMoist, var = "C_R_mrn")

# Fit a temprature function to each moisture subgroup and plot
FitTemp <- function(df, var) {
  df$C_R <- df[[var]]
  fitExp <- lm(log(C_R) ~ temp, data = df)
  l1 <- list(site = df$site[1], moist_vol = df$moist_vol[1], fitExp = fitExp, Q10 = exp(10*coef(fitExp)[[2]]))
  fitEafun <- function(df, Ea) { nls(C_R ~ C_R_ref * exp(-Ea/0.008314*(1/(temp+273) - 1/273)),
                                     start=c(C_R_ref = 0.1, Ea = 100), algorithm="port", data = df) }
  fitEa <- try(fitEafun(df, 100))
  if(class(fitEa)=="try-error") fitEa <- try(fitEafun(df, 40))
  if(class(fitEa)!="try-error") {l1 <- c(l1, list(fitEa = fitEa, C_R_ref = coef(fitEa)[[1]], Ea = coef(fitEa)[[2]]))}
  return(l1)
}

# For for entire temperature range
fit.temp.obs <- dlply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_ro")
fit.temp.mod <- dlply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_rm")
# Fit for 5C to 20C
fit.temp.obs.5_20 <- dlply(data.accum[data.accum$temp!=35,], .(moist.group), .fun = FitTemp, var = "C_R_ro")
fit.temp.mod.5_20 <- dlply(data.accum[data.accum$temp!=35,], .(moist.group), .fun = FitTemp, var = "C_R_rm")
# Fit for 20C to 35C
fit.temp.obs.20_35 <- dlply(data.accum[data.accum$temp!=5,], .(moist.group), .fun = FitTemp, var = "C_R_ro")
fit.temp.mod.20_35 <- dlply(data.accum[data.accum$temp!=5,], .(moist.group), .fun = FitTemp, var = "C_R_rm")

source('post_process_plots.R')

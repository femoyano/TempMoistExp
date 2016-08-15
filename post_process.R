### ===================================== ###
### Post-process at end of run ###
### ===================================== ###


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

pars_replace <- mcmcMod$bestpar
pars <- ParsReplace(pars_replace, pars_default)

source("GetModelData.R")

# Get model output with optimized parameters
system.time(mod.out <- GetModelData(pars))

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
    fit <- nls(C_R ~ Rmax * ifelse((moist_vol - Th) < 0, 0, (moist_vol - Th)^2 / (K^2 + (moist_vol - Th)^2)),
               start=c(Rmax=1, Th=0.1, K=0.15), lower=c(Rmax=0.5, Th=0, K=0.01),
               upper=c(Rmax=1.5, Th=0.2, K=0.25), algorithm="port", data = df)
    return(list(fit = fit, Rmax = coef(fit)[1], Th = coef(fit)[2], K = coef(fit)[3],
                site = df$site[1], temp = df$temp[1]))
}
fit.moist.obs <- dlply(data.accum, .(temp.group), .fun = FitMoist, var = "C_R_orn")
fit.moist.mod <- dlply(data.accum, .(temp.group), .fun = FitMoist, var = "C_R_mrn")

# Fit a temprature function to each moisture subgroup and plot
FitTemp <- function(df, var) {
  df$C_R <- df[[var]]
  fitEa <- nls(C_R ~ C_R_ref * exp(-Ea/0.008314*(1/(temp+273) - 1/273)),
             start=c(C_R_ref = 0.1, Ea = 100), algorithm="port", data = df)
  fitExp <- lm(log(C_R) ~ temp, data = df)
  return(list(fitEa = fitEa, fitExp = fitExp, C_R_ref = coef(fitEa)[1], Ea = coef(fitEa)[2],
              Q10 = exp(10*coef(fitExp)[2]), site = df$site[1], moist_vol = df$moist_vol[1]))
}
# For for entire temperature range
fit.temp.obs <- dlply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_or")
fit.temp.mod <- dlply(data.accum, .(moist.group), .fun = FitTemp, var = "C_R_mr")
# Fit for 5C to 20C
fit.temp.obs.5_20 <- dlply(data.accum[data.accum$temp!=35,], .(moist.group), .fun = FitTemp, var = "C_R_or")
fit.temp.mod.5_20 <- dlply(data.accum[data.accum$temp!=35,], .(moist.group), .fun = FitTemp, var = "C_R_mr")
# Fit for 20C to 35C
fit.temp.obs.20_35 <- dlply(data.accum[data.accum$temp!=5,], .(moist.group), .fun = FitTemp, var = "C_R_or")
fit.temp.mod.20_35 <- dlply(data.accum[data.accum$temp!=5,], .(moist.group), .fun = FitTemp, var = "C_R_mr")

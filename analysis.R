# analysis.R
# analyse and plot model vs observation

mod.data <- GetModelData(data.accum, input.all, Modfit)
list2env(mod.data, envir = .GlobalEnv)
rm(mod.data)

# Function that returns Root Mean Squared Error
rmse <- function(error) sqrt(mean(error^2))

# Function that returns Mean Absolute Error
mae <- function(error) mean(abs(error))

res <- data.meas$C_R - data.meas$C_R_m
RMSE <- rmse(res)
MAE <- mae(res)
plotname <- paste("mod-obs", runtime, "png", sep = "_")
plotfile <- file.path("..", "Analysis", "NadiaTempMoist", plotname)
png(file = plotfile)
plot(data.accum$C_R, data.accum$C_R_m)

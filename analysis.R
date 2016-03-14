# analysis.R
# analyse and plot model vs observation
mod.out <- GetModelData(input.all, fitMod$par)
data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"), by.y = c("sample", "time"))

# Function that returns Root Mean Squared Error
rmse <- function(res) sqrt(mean(error^2))

# Function that returns Mean Absolute Error
mae <- function(res) mean(abs(error))

res <- data.accum$C_R - data.accum$C_R_m
RMSE <- rmse(res)
MAE <- mae(res)

plotname <- paste("mod-obs", runtime, "png", sep = "_")
plotfile <- file.path("..", "Analysis", "NadiaTempMoist", plotname)
png(file = plotfile)
plot(data.accum$C_R, data.accum$C_R_m)


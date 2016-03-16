# analysis.R
# analyse and plot model vs observation

# # Visually explore the correlation between parameter sensitivities:
par_corr_plot <- pairs(Sfun, which = c("C_R"), col = c("blue", "green"))
ident <- collin(Sfun)
ident_plot <- plot(ident, ylim=c(0,20))
ident[ident$N==9 & ident$collinearity<15,]

mod.out <- GetModelData(input.all, fitMod$par)
data.accum <- merge(obs.accum, AccumCalc(mod.out, obs.accum), by.x = c("sample", "hour"), by.y = c("sample", "time"))

# Function that returns Root Mean Squared Error
rmse <- function(res) sqrt(mean(res^2))

# Function that returns Mean Absolute Error
mae <- function(res) mean(abs(res))

res <- data.accum$C_R - data.accum$C_R_m
RMSE <- rmse(res)
MAE <- mae(res)

plotname <- paste("mod-obs", runtime, "png", sep = "_")
plotfile <- file.path("..", "Analysis", "NadiaTempMoist", plotname)
png(file = plotfile)
plot(data.accum$C_R, data.accum$C_R_m)


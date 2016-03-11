# ParSens.R
# Check and plor sensitivity of parameters ---------------

ParSens <- function(ModCost, pars_optim) {
  Sfun <- sensFun(ModCost, pars_optim)
  # Plot the parameter sensitivities through time
  par_sens_plot <- plot(Sfun, which = c("C_R"), xlab = hour, lwd = 2)
  # Visually explore the correlation between parameter sensitivities:
  par_corr_plot <- pairs(Sfun, which = c("C_R"), col = c("blue", "green"))
  ident <- collin(Sfun)
  ident_plot <- plot(ident, ylim=c(0,20))
  ident[ident$N==8 & ident$collinearity<15,]
  return(list(Sfun, par_sens_plot, par_corr_plot, ident, ident_plot))
}

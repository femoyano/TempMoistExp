# ParsReplace.R
# Adds or replaces parameters from the list of optimized parameters ----------------------

ParsReplace <- function(pars_optim, pars) {
  for(n in names(pars_optim)) pars[[n]] <- pars_optim[[n]]
  # Replace param values where assignment is required
  pars[["E_r_d"]] <- pars[["E_V"]]
  if("E_k" %in% names(pars_optim)) pars[["E_ka"]] <- pars[["E_kd"]] <- pars[["E_k"]]
  return(pars)
}
